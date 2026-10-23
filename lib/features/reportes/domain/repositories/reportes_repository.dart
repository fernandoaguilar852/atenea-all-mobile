import '../../data/models/arqueo_reporte.dart';
import '../../data/models/costo_beneficio_reporte.dart';
import '../../data/models/inventario_reporte.dart';
import '../../data/models/stock_reporte.dart';
import '../../data/models/venta_detalle_reporte.dart';
import '../../data/models/ventas_reporte.dart';

/// Repository interface para reportes
/// Define el contrato para acceso a datos de reportes
abstract class ReportesRepository {
  /// Obtiene reporte de ventas
  Future<VentasReporte> getVentasReporte({
    required int clienteId,
    required String startDate,
    required String endDate,
    String? nombreProducto,
    int? categoriaId,
    int? cajaId,
    int pageNumber = 1,
    int pageSize = 10,
  });

  /// Obtiene reporte de venta detallada
  Future<VentaDetalleReporte> getVentaDetalleReporte({
    required int clienteId,
    required String startDate,
    required String endDate,
    int pageNumber = 1,
    int pageSize = 10,
  });

  /// Obtiene reporte de inventario consumido
  Future<InventarioReporte> getInventarioReporte({
    required int clienteId,
    required String startDate,
    required String endDate,
    int pageNumber = 1,
    int pageSize = 10,
  });

  /// Obtiene reporte de arqueo de caja
  /// Este reporte NO tiene paginación
  Future<ArqueoReporte> getArqueoReporte({
    required int clienteId,
    required String startDate,
    required String endDate,
    int? cajaId,
  });

  /// Obtiene reporte de stock de productos
  Future<StockReporte> getStockReporte({
    required int clienteId,
    bool? activo,
    int pageNumber = 1,
    int pageSize = 10,
  });

  /// Obtiene reporte de costo-beneficio
  Future<CostoBeneficioReporte> getCostoBeneficioReporte({
    required int clienteId,
    required String startDate,
    required String endDate,
    int pageNumber = 1,
    int pageSize = 10,
  });
}
