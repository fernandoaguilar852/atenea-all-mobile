import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/resolucion_model.dart';

/// Datasource remoto para Resoluciones
/// Realiza las llamadas HTTP a la API
class ResolucionesRemoteDatasource {
  final Dio _dio;

  ResolucionesRemoteDatasource(this._dio);

  /// GET /resoluciones - Lista resoluciones con paginación
  Future<ResolucionesResponse> getResoluciones({
    required int clienteId,
    int pageNumber = 1,
    int pageSize = 10,
    bool? activo,
  }) async {
    final queryParams = <String, dynamic>{
      'clienteId': clienteId,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    if (activo != null) {
      queryParams['activo'] = activo;
    }

    final response = await _dio.get(
      ApiConstants.buildUrl('/resoluciones'),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return ResolucionesResponse.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener resoluciones',
      );
    }
  }

  /// POST /resoluciones - Crea una nueva resolución
  Future<ResolucionSingleResponse> createResolucion({
    required Map<String, dynamic> data,
    required int clienteId,
  }) async {
    final response = await _dio.post(
      ApiConstants.buildUrl('/resoluciones'),
      data: data,
      queryParameters: {'clienteId': clienteId},
    );

    if (response.statusCode == 201 && response.data['data'] != null) {
      return ResolucionSingleResponse.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al crear resolución',
      );
    }
  }

  /// PATCH /resoluciones/:id - Actualiza una resolución
  Future<ResolucionSingleResponse> updateResolucion({
    required int resolucionId,
    required int clienteId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.patch(
      ApiConstants.buildUrl('/resoluciones/$resolucionId'),
      queryParameters: {'clienteId': clienteId},
      data: data,
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return ResolucionSingleResponse.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al actualizar resolución',
      );
    }
  }

  /// DELETE /resoluciones/:id - Elimina una resolución
  Future<void> deleteResolucion({
    required int resolucionId,
    required int clienteId,
  }) async {
    final response = await _dio.delete(
      ApiConstants.buildUrl('/resoluciones/$resolucionId'),
      queryParameters: {'clienteId': clienteId},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al eliminar resolución',
      );
    }
  }
}
