import '../../data/models/dashboard_stats.dart';

/// Repository interface para dashboard
/// Define el contrato para acceso a estadísticas del dashboard
abstract class DashboardRepository {
  /// Obtiene las estadísticas del dashboard para un rango de fechas
  Future<DashboardStats> getStats({
    required int clienteId,
    required String startDate,
    required String endDate,
  });
}
