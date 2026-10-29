import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/notificacion_model.dart';

/// Datasource remoto para Notificaciones
class NotificacionesRemoteDatasource {
  final Dio _dio;

  NotificacionesRemoteDatasource(this._dio);

  /// GET /v1/pos/notificaciones - Lista notificaciones con paginación
  Future<NotificacionesListResponse> listNotificaciones({
    required int clienteId,
    String? estado,
    int pageSize = 10,
    int pageNumber = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'clienteId': clienteId,
        'pageSize': pageSize,
        'pageNumber': pageNumber,
      };

      if (estado != null) {
        queryParams['estado'] = estado;
      }

      final response = await _dio.get(
        ApiConstants.buildUrl('/notificaciones'),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        // Pasar todo el response.data que incluye 'data' y 'pagination'
        return NotificacionesListResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Error al obtener notificaciones: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        message:
            'Error al obtener notificaciones: ${e.response?.statusCode ?? "Sin conexión"}',
      );
    }
  }

  /// GET /v1/pos/notificaciones/{id} - Obtiene notificación por ID
  Future<NotificacionModel> getNotificacionById({
    required int clienteId,
    required int notificacionId,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.buildUrl('/notificaciones/$notificacionId'),
        queryParameters: {'clienteId': clienteId},
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        return NotificacionModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Error al obtener notificación: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        message:
            'Error al obtener notificación: ${e.response?.statusCode ?? "Sin conexión"}',
      );
    }
  }

  /// GET /v1/pos/notificaciones/pendientes - Obtiene notificaciones pendientes
  Future<NotificacionesListResponse> getNotificacionesPendientes({
    required int clienteId,
    int pageSize = 10,
    int pageNumber = 1,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.buildUrl('/notificaciones/pendientes'),
        queryParameters: {
          'clienteId': clienteId,
          'pageSize': pageSize,
          'pageNumber': pageNumber,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        // Pasar todo el response.data que incluye 'data' y 'pagination'
        return NotificacionesListResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message:
              'Error al obtener notificaciones pendientes: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        message:
            'Error al obtener notificaciones pendientes: ${e.response?.statusCode ?? "Sin conexión"}',
      );
    }
  }

  /// PATCH /v1/pos/notificaciones/{id} - Actualiza estado de notificación
  Future<NotificacionModel> updateEstadoNotificacion({
    required int clienteId,
    required int notificacionId,
    required String estado,
  }) async {
    try {
      final response = await _dio.patch(
        ApiConstants.buildUrl('/notificaciones/$notificacionId'),
        queryParameters: {'clienteId': clienteId},
        data: {'estado': estado},
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        return NotificacionModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Error al actualizar notificación: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        message:
            'Error al actualizar notificación: ${e.response?.statusCode ?? "Sin conexión"}',
      );
    }
  }

  /// DELETE /v1/pos/notificaciones/{id} - Elimina notificación
  Future<void> deleteNotificacion({
    required int clienteId,
    required int notificacionId,
  }) async {
    try {
      final response = await _dio.delete(
        ApiConstants.buildUrl('/notificaciones/$notificacionId'),
        queryParameters: {'clienteId': clienteId},
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Error al eliminar notificación: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        message:
            'Error al eliminar notificación: ${e.response?.statusCode ?? "Sin conexión"}',
      );
    }
  }
}
