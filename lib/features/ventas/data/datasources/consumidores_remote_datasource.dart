import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/venta_model.dart';
import '../models/consumidor_search_model.dart';

/// Datasource remoto para Consumidores
class ConsumidoresRemoteDatasource {
  final Dio _dio;

  ConsumidoresRemoteDatasource(this._dio);

  /// GET /v1/pos/consumidores/{id} - Obtiene información completa de un consumidor
  Future<ConsumidorModel> getConsumidorById({
    required int clienteId,
    required int consumidorId,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.buildUrl('/consumidores/$consumidorId'),
        queryParameters: {'clienteId': clienteId},
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        return ConsumidorModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Error al obtener consumidor: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        message: 'Error al obtener consumidor: ${e.response?.statusCode ?? "Sin conexión"}',
      );
    }
  }

  /// GET /v1/pos/consumidores - Busca consumidores por término de búsqueda
  Future<ConsumidorSearchResponse> searchConsumidores({
    required int clienteId,
    required String search,
    int pageSize = 10,
    int pageNumber = 1,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.buildUrl('/consumidores'),
        queryParameters: {
          'clienteId': clienteId,
          'search': search,
          'pageSize': pageSize,
          'pageNumber': pageNumber,
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        return ConsumidorSearchResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Error al buscar consumidores: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        message: 'Error al buscar consumidores: ${e.response?.statusCode ?? "Sin conexión"}',
      );
    }
  }
}
