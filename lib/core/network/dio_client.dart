import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:uuid/uuid.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

class DioClient {
  late final Dio _dio;
  final SecureStorageService _secureStorage;

  DioClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      ),
    );

    _dio.interceptors.addAll([
      _headerInterceptor(),
      _authInterceptor(),
      if (kDebugMode) _loggingInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  // Header Interceptor - Agrega headers requeridos
  Interceptor _headerInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // Agregar UUID único por request
        options.headers[ApiConstants.headerMessageUuid] = const Uuid().v4();

        // Agregar App ID
        options.headers[ApiConstants.headerRequestAppId] = ApiConstants.appId;

        return handler.next(options);
      },
    );
  }

  // Auth Interceptor - Agrega token de autenticación
  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Endpoints que NO requieren token
        final publicEndpoints = [
          '/login',
          '/login/recuperar',
          '/login/reset-password-with-code',
          '/login/validar-token',
          '/publico/',
        ];

        // Verificar si es endpoint público
        final isPublic = publicEndpoints.any(
          (endpoint) => options.path.contains(endpoint),
        );

        if (!isPublic) {
          // Obtener token del storage
          final token = await _secureStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers[ApiConstants.headerAuthorization] = 'Bearer $token';
          }
        }

        return handler.next(options);
      },
      onError: (error, handler) async {
        // Si es error 401 (Unauthorized)
        if (error.response?.statusCode == 401) {
          // Intentar refrescar el token
          final refreshed = await _refreshToken();

          if (refreshed) {
            // Reintentar la petición original
            final token = await _secureStorage.getAccessToken();
            error.requestOptions.headers[ApiConstants.headerAuthorization] =
                'Bearer $token';

            try {
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              return handler.reject(error);
            }
          } else {
            // No se pudo refrescar, logout
            await _secureStorage.clearAll();
            // TODO: Navegar a login
            return handler.reject(error);
          }
        }

        return handler.next(error);
      },
    );
  }

  // Logging Interceptor - Solo en debug
  Interceptor _loggingInterceptor() {
    return PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    );
  }

  // Refresh Token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final response = await _dio.post(
        ApiConstants.buildUrl(ApiConstants.refresh),
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final newAccessToken = response.data['data']['accessToken'] as String?;
        final newRefreshToken = response.data['data']['refreshToken'] as String?;

        if (newAccessToken != null) {
          await _secureStorage.saveAccessToken(newAccessToken);
          if (newRefreshToken != null) {
            await _secureStorage.saveRefreshToken(newRefreshToken);
          }
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return false;
    }
  }
}
