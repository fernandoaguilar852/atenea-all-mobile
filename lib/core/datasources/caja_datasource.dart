import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/caja.dart';

/// Datasource para cajas
class CajaDatasource {
  final Dio _dio;

  CajaDatasource(this._dio);

  /// Obtiene lista de cajas
  Future<List<Caja>> getCajas({
    required int clienteId,
    String? estado,
    int pageNumber = 1,
    int pageSize = 100,
  }) async {
    final queryParams = <String, dynamic>{
      'clienteId': clienteId,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    if (estado != null && estado.isNotEmpty) {
      queryParams['estado'] = estado;
    }

    final response = await _dio.get(
      ApiConstants.buildUrl('/v1/pos/cajas'),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      final CajaData cajaData = CajaData.fromJson(response.data['data']);
      return cajaData.cajas;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener cajas',
      );
    }
  }
}
