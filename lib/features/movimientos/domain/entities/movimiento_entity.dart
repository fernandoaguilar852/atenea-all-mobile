/// Entidad de dominio para Movimiento de Inventario
class MovimientoEntity {
  final int movimientoId;
  final int productoId;
  final String? nombreProducto;
  final int usuarioId;
  final int clienteId;
  final int? proveedorId;
  final int? cajaId;
  final int? pagoId;
  final int? ventaId;
  final TipoMovimiento tipo;
  final double costo;
  final double impuesto;
  final double descuentoUnidad;
  final double cantidad;
  final String? observacion;
  final DateTime fecha;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? updatedByUsuarioId;
  final DateTime? deletedAt;
  final int? deletedByUsuarioId;
  final String? deleteReason;

  const MovimientoEntity({
    required this.movimientoId,
    required this.productoId,
    this.nombreProducto,
    required this.usuarioId,
    required this.clienteId,
    this.proveedorId,
    this.cajaId,
    this.pagoId,
    this.ventaId,
    required this.tipo,
    required this.costo,
    required this.impuesto,
    required this.descuentoUnidad,
    required this.cantidad,
    this.observacion,
    required this.fecha,
    required this.createdAt,
    this.updatedAt,
    this.updatedByUsuarioId,
    this.deletedAt,
    this.deletedByUsuarioId,
    this.deleteReason,
  });

  /// Total del movimiento
  double get total => (costo + impuesto - descuentoUnidad) * cantidad;

  /// Si está eliminado (soft delete)
  bool get isDeleted => deletedAt != null;
}

/// Tipos de movimiento de inventario
enum TipoMovimiento {
  entrada,
  salida,
  venta,
  ajuste,
  merma,
  ingreso,
  egreso;

  String get displayName {
    switch (this) {
      case TipoMovimiento.entrada:
        return 'Entrada';
      case TipoMovimiento.salida:
        return 'Salida';
      case TipoMovimiento.venta:
        return 'Venta';
      case TipoMovimiento.ajuste:
        return 'Ajuste';
      case TipoMovimiento.merma:
        return 'Merma';
      case TipoMovimiento.ingreso:
        return 'Ingreso';
      case TipoMovimiento.egreso:
        return 'Egreso';
    }
  }
}

/// Paginación para listado de movimientos
class MovimientosPaginacion {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final bool hasNext;
  final bool hasPrevious;

  const MovimientosPaginacion({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.hasNext,
    required this.hasPrevious,
  });
}

/// Respuesta paginada de movimientos
class MovimientosListEntity {
  final List<MovimientoEntity> movimientos;
  final MovimientosPaginacion? pagination;

  const MovimientosListEntity({
    required this.movimientos,
    this.pagination,
  });
}
