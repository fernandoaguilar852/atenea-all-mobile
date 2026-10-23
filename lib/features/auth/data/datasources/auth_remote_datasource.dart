import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.buildUrl(ApiConstants.auth),
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        return LoginResponse.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['messageResponse']?['responseMessage'] ??
              'Error al iniciar sesión',
        );
      }
    } on DioException catch (e) {
      if (e.response?.data?['messageResponse']?['responseMessage'] != null) {
        throw Exception(
          e.response!.data['messageResponse']['responseMessage'],
        );
      }
      throw Exception('Error de conexión. Verifica tu internet.');
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.buildUrl(ApiConstants.logout));
    } catch (e) {
      // Ignorar errores en logout (offline, etc.)
    }
  }

  Future<Map<String, String>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        ApiConstants.buildUrl(ApiConstants.refresh),
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        return {
          'accessToken': response.data['data']['accessToken'],
          'refreshToken': response.data['data']['refreshToken'],
        };
      } else {
        throw Exception('Error al refrescar token');
      }
    } catch (e) {
      throw Exception('Error al refrescar token');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        ApiConstants.buildUrl(ApiConstants.recuperar),
        data: {'email': email},
      );

      if (response.statusCode != 200) {
        throw Exception(
          response.data['messageResponse']?['responseMessage'] ??
              'Error al enviar código',
        );
      }
    } on DioException catch (e) {
      if (e.response?.data?['messageResponse']?['responseMessage'] != null) {
        throw Exception(
          e.response!.data['messageResponse']['responseMessage'],
        );
      }
      throw Exception('Error de conexión');
    }
  }

  Future<void> resetPassword({
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.buildUrl(ApiConstants.resetPassword),
        data: {
          'code': code,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          response.data['messageResponse']?['responseMessage'] ??
              'Error al restablecer contraseña',
        );
      }
    } on DioException catch (e) {
      if (e.response?.data?['messageResponse']?['responseMessage'] != null) {
        throw Exception(
          e.response!.data['messageResponse']['responseMessage'],
        );
      }
      throw Exception('Error de conexión');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.buildUrl(ApiConstants.cambiarPassword),
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          response.data['messageResponse']?['responseMessage'] ??
              'Error al cambiar contraseña',
        );
      }
    } on DioException catch (e) {
      if (e.response?.data?['messageResponse']?['responseMessage'] != null) {
        throw Exception(
          e.response!.data['messageResponse']['responseMessage'],
        );
      }
      throw Exception('Error de conexión');
    }
  }

  Future<bool> validateToken() async {
    try {
      final response = await _dio.get(
        ApiConstants.buildUrl(ApiConstants.validarToken),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
