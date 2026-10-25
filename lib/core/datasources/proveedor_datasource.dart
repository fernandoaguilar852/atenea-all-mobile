import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/proveedor.dart';

class ProveedorDatasource {
  final Dio _dio;

  ProveedorDatasource(this._dio);

  /// Buscar proveedores por término de búsqueda
  Future<List<Proveedor>> searchProveedores({
    required int clienteId,
    required String search,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.buildUrl('/proveedores'),
      queryParameters: {
        'clienteId': clienteId,
        'search': search,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      final proveedoresResponse = ProveedoresResponse.fromJson(response.data);
      return proveedoresResponse.data.proveedores;
    }

    return [];
  }
}
