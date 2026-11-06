import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/iva.dart';

/// Datasource para IVAs
class IvaDatasource {
  final Dio _dio;

  IvaDatasource(this._dio);

  /// Lista todos los IVAs activos
  Future<List<Iva>> getIvas({
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    final response = await _dio.get(
      ApiConstants.buildUrl('/ivas'),
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      final IvaData ivaData = IvaData.fromJson(response.data['data']);
      return ivaData.ivas;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener IVAs',
      );
    }
  }
}
