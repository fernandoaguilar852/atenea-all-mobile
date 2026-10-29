import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/alerta_stock_model.dart';

/// Datasource remoto para Alertas de Stock
class AlertasStockRemoteDatasource {
  final Dio _dio;

  AlertasStockRemoteDatasource(this._dio);

  /// GET /v1/pos/alertas-stock - Lista alertas de stock con paginación
  Future<AlertasStockListResponse> listAlertasStock({
    required int clienteId,
    int pageSize = 10,
    int pageNumber = 1,
    int? productoId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'clienteId': clienteId,
        'pageSize': pageSize,
        'pageNumber': pageNumber,
      };

      if (productoId != null) {
        queryParams['productoId'] = productoId;
      }

      final response = await _dio.get(
        ApiConstants.buildUrl('/alertas-stock'),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        // Extraer solo 'data' y 'pagination' del response
        final responseData = {
          'data': response.data['data'],
          'pagination': response.data['pagination'],
        };
        return AlertasStockListResponse.fromJson(responseData);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Error al obtener alertas de stock: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        message:
            'Error al obtener alertas de stock: ${e.response?.statusCode ?? "Sin conexión"}',
      );
    }
  }
}
