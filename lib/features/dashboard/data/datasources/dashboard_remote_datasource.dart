import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/dashboard_stats.dart';

/// Datasource remoto para dashboard
/// Maneja las llamadas HTTP para estadísticas del dashboard
class DashboardRemoteDatasource {
  final Dio _dio;

  DashboardRemoteDatasource(this._dio);

  /// Obtiene las estadísticas del dashboard desde el API
  Future<DashboardStats> getStats({
    required int clienteId,
    required String startDate,
    required String endDate,
  }) async {
    final response = await _dio.get(
      ApiConstants.buildUrl(ApiConstants.consultaEstadisticas),
      queryParameters: {
        'clienteId': clienteId,
        'startDate': startDate,
        'endDate': endDate,
      },
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return DashboardStats.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener estadísticas',
      );
    }
  }
}
