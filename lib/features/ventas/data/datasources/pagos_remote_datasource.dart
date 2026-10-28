import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/pago_model.dart';

/// Datasource remoto para Pagos
class PagosRemoteDatasource {
  final Dio _dio;

  PagosRemoteDatasource(this._dio);

  /// GET /v1/pos/pagos/{id} - Obtiene información de un método de pago
  Future<PagoModel> getPagoById(int pagoId) async {
    try {
      final response = await _dio.get(
        ApiConstants.buildUrl('/pagos/$pagoId'),
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        return PagoModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Error al obtener información del pago: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        message: 'Error al obtener pago: ${e.response?.statusCode ?? "Sin conexión"}',
      );
    }
  }
}
