import '../../domain/entities/alerta_stock_entity.dart';
import '../../domain/repositories/alertas_stock_repository.dart';
import '../datasources/alertas_stock_remote_datasource.dart';

/// Implementación del repositorio de Alertas de Stock
class AlertasStockRepositoryImpl implements AlertasStockRepository {
  final AlertasStockRemoteDatasource _remoteDatasource;

  AlertasStockRepositoryImpl(this._remoteDatasource);

  @override
  Future<AlertasStockResponse> listAlertasStock({
    required int clienteId,
    int pageSize = 10,
    int pageNumber = 1,
    int? productoId,
  }) async {
    final response = await _remoteDatasource.listAlertasStock(
      clienteId: clienteId,
      pageSize: pageSize,
      pageNumber: pageNumber,
      productoId: productoId,
    );

    return response.toAlertasStockResponse();
  }
}
