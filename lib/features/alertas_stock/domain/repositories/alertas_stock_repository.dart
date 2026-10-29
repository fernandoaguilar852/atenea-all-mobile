import '../entities/alerta_stock_entity.dart';

/// Repository interface para Alertas de Stock
abstract class AlertasStockRepository {
  /// Lista alertas de stock con paginación
  Future<AlertasStockResponse> listAlertasStock({
    required int clienteId,
    int pageSize = 10,
    int pageNumber = 1,
    int? productoId,
  });
}
