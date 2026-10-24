import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/tipo_producto.dart';

/// Datasource para tipos de producto
class TipoProductoDatasource {
  final Dio _dio;

  TipoProductoDatasource(this._dio);

  /// Obtiene lista de tipos de producto
  Future<List<TipoProducto>> getTiposProducto({
    required int clienteId,
    int pageNumber = 1,
    int pageSize = 100,
  }) async {
    final response = await _dio.get(
      ApiConstants.buildUrl('/v1/pos/tipos-producto'),
      queryParameters: {
        'clienteId': clienteId,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => TipoProducto.fromJson(json)).toList();
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener tipos de producto',
      );
    }
  }
}
