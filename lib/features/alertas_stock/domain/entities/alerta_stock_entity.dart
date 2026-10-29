/// Entidad de dominio para Alerta de Stock
class AlertaStockEntity {
  final int alertaId;
  final int productoId;
  final int clienteId;
  final String nombreProducto;
  final int stockActual;
  final int stockMinimo;
  final DateTime fechaAlerta;
  final DateTime? updatedAt;
  final double? porcentajeStock;
  final int diasEnAlerta;

  const AlertaStockEntity({
    required this.alertaId,
    required this.productoId,
    required this.clienteId,
    required this.nombreProducto,
    required this.stockActual,
    required this.stockMinimo,
    required this.fechaAlerta,
    this.updatedAt,
    this.porcentajeStock,
    required this.diasEnAlerta,
  });
}

/// Response del listado de alertas con paginación
class AlertasStockResponse {
  final List<AlertaStockEntity> alertas;
  final int totalElement;
  final int pageSize;
  final int pageNumber;
  final bool hasMoreElements;

  const AlertasStockResponse({
    required this.alertas,
    required this.totalElement,
    required this.pageSize,
    required this.pageNumber,
    required this.hasMoreElements,
  });
}
