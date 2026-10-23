import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/dashboard_stats.dart';

/// Implementación del repositorio de dashboard
/// Coordina el acceso a datos desde datasources
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDatasource _remoteDatasource;

  DashboardRepositoryImpl(this._remoteDatasource);

  @override
  Future<DashboardStats> getStats({
    required int clienteId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      return await _remoteDatasource.getStats(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }
}
