import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/producto.dart';

/// Datasource para productos
class ProductoDatasource {
  final Dio _dio;

  ProductoDatasource(this._dio);

  /// Busca productos por nombre
  Future<List<Producto>> searchProductos({
    required int clienteId,
    required String search,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.buildUrl('/products'),
      queryParameters: {
        'clienteId': clienteId,
        'search': search,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      final ProductoData productoData = ProductoData.fromJson(response.data['data']);
      return productoData.products;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al buscar productos',
      );
    }
  }
}
