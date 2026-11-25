import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/cotizacion_model.dart';

/// Datasource remoto para Cotizaciones
/// Realiza las llamadas HTTP a la API
class CotizacionesRemoteDatasource {
  final Dio _dio;

  // Origen fijo por ahora (se convertirá en filtro en una próxima iteración)
  static const String _origenPosInterno = 'POS-INTERNO';

  CotizacionesRemoteDatasource(this._dio);

  /// GET /cotizaciones - Lista cotizaciones con paginación
  Future<CotizacionesResponse> getCotizaciones({
    required int clienteId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'clienteId': clienteId,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'origen': _origenPosInterno,
    };

    final response = await _dio.get(
      ApiConstants.buildUrl(ApiConstants.cotizaciones),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return CotizacionesResponse.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener cotizaciones',
      );
    }
  }
}
