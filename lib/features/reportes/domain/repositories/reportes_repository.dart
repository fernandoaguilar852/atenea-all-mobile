import '../entities/arqueo_entity.dart';
import '../entities/costo_beneficio_entity.dart';
import '../entities/inventario_entity.dart';
import '../entities/stock_entity.dart';
import '../entities/venta_detalle_entity.dart';
import '../entities/ventas_entity.dart';

/// Repository interface para reportes
/// Define el contrato para acceso a datos de reportes
abstract class ReportesRepository {
  /// Obtiene reporte de ventas
  Future<VentasEntity> getVentasReporte({
    required int clienteId,
    required String startDate,
    required String endDate,
    int? productoId,
    String? nombreProducto,
    int? consumidorId,
    int? categoriaId,
    int? cajaId,
    bool? incluirAnuladas,
    int pageNumber = 1,
    int pageSize = 10,
  });

  /// Obtiene reporte de venta detallada
  Future<VentaDetalleEntity> getVentaDetalleReporte({
    required int clienteId,
    String? startDate,
    String? endDate,
    int? consumidorId,
    String? estado,
    int? productoId,
    int pageNumber = 1,
    int pageSize = 10,
  });

  /// Obtiene reporte de inventario consumido
  Future<InventarioEntity> getInventarioReporte({
    required int clienteId,
    required String startDate,
    required String endDate,
    int? productoId,
    String? tipoMovimiento,
    int pageNumber = 1,
    int pageSize = 10,
  });

  /// Obtiene reporte de arqueo de caja
  /// Este reporte NO tiene paginación
  Future<ArqueoEntity> getArqueoReporte({
    required int clienteId,
    required String startDate,
    required String endDate,
    int? cajaId,
    String? tipoPago,
  });

  /// Obtiene reporte de stock de productos
  Future<StockEntity> getStockReporte({
    required int clienteId,
    int? productoId,
    bool? stockBajo,
    bool? activo,
    int? tipoProductoId,
    int pageNumber = 1,
    int pageSize = 10,
  });

  /// Obtiene reporte de costo-beneficio
  Future<CostoBeneficioEntity> getCostoBeneficioReporte({
    required int clienteId,
    required String startDate,
    required String endDate,
    int? productoId,
    int? categoriaId,
    bool? activo,
    int pageNumber = 1,
    int pageSize = 10,
  });
}
