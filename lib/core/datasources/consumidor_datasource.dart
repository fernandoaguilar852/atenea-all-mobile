import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/consumidor.dart';

/// Datasource global para consumidores (clientes del negocio)
class ConsumidorDatasource {
  final Dio _dio;

  ConsumidorDatasource(this._dio);

  /// GET /consumidores - Lista consumidores con paginación y filtros
  /// (search: texto a buscar; activo: true/false, null = todos)
  Future<ConsumidorResponse> getConsumidores({
    required int clienteId,
    int pageNumber = 1,
    int pageSize = 10,
    String? search,
    bool? activo,
  }) async {
    final queryParams = <String, dynamic>{
      'clienteId': clienteId,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    // Los filtros solo se envían si tienen valor
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (activo != null) {
      queryParams['activo'] = activo;
    }

    final response = await _dio.get(
      ApiConstants.buildUrl(ApiConstants.consumidores),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return ConsumidorResponse.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener consumidores',
      );
    }
  }

  /// Busca consumidores por nombre
  Future<List<Consumidor>> searchConsumidores({
    required int clienteId,
    required String search,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.buildUrl('/consumidores'),
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
