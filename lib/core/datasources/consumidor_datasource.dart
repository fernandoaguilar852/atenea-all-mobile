import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/consumidor.dart';

/// Datasource para consumidores
class ConsumidorDatasource {
  final Dio _dio;

  ConsumidorDatasource(this._dio);

  /// Busca consumidores por nombre
  Future<List<Consumidor>> searchConsumidores({
    required int clienteId,
    required String search,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.buildUrl('/v1/pos/consumidores'),
      queryParameters: {
        'clienteId': clienteId,
        'search': search,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Consumidor.fromJson(json)).toList();
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al buscar consumidores',
      );
    }
  }
}
