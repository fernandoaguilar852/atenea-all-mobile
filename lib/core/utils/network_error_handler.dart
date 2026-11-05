import 'package:dio/dio.dart';

/// Helper para manejar errores de red de forma amigable
class NetworkErrorHandler {
  /// Obtiene un mensaje de error amigable para el usuario
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'La conexión está tardando mucho. Por favor verifica tu internet e intenta nuevamente.';

        case DioExceptionType.sendTimeout:
          return 'No se pudo enviar la información. Verifica tu conexión a internet.';

        case DioExceptionType.receiveTimeout:
          return 'El servidor está tardando en responder. Intenta nuevamente.';

        case DioExceptionType.connectionError:
          return 'No hay conexión a internet. Por favor verifica tu conexión.';

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode != null) {
            if (statusCode >= 500) {
              return 'El servidor está teniendo problemas. Intenta más tarde.';
            } else if (statusCode == 404) {
              return 'No se encontró la información solicitada.';
            } else if (statusCode == 401) {
              return 'Tu sesión ha expirado. Por favor inicia sesión nuevamente.';
            } else if (statusCode == 403) {
              return 'No tienes permisos para acceder a esta información.';
            }
          }

          // Intentar obtener mensaje del servidor
          final serverMessage = error.response?.data?['messageResponse']?['responseMessage'];
          if (serverMessage != null && serverMessage.toString().isNotEmpty) {
            return serverMessage.toString();
          }

          return 'Hubo un problema al procesar tu solicitud.';

        case DioExceptionType.cancel:
          return 'La operación fue cancelada.';

        case DioExceptionType.badCertificate:
          return 'Problema de seguridad con la conexión.';

        case DioExceptionType.unknown:
        default:
          return 'Ocurrió un error inesperado. Intenta nuevamente.';
      }
    }

    return 'Ocurrió un error inesperado. Intenta nuevamente.';
  }

  /// Verifica si es un error de conexión
  static bool isConnectionError(dynamic error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError;
    }
    return false;
  }

  /// Verifica si es un error del servidor (5xx)
  static bool isServerError(dynamic error) {
    if (error is DioException && error.response != null) {
      final statusCode = error.response!.statusCode;
      return statusCode != null && statusCode >= 500;
    }
    return false;
  }

  /// Verifica si es un error de autenticación
  static bool isAuthError(dynamic error) {
    if (error is DioException && error.response != null) {
      final statusCode = error.response!.statusCode;
      return statusCode == 401 || statusCode == 403;
    }
    return false;
  }
}
