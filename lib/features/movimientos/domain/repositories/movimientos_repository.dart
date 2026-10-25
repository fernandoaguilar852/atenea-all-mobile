import '../entities/movimiento_entity.dart';

/// Repositorio abstracto para Movimientos de Inventario
/// Define el contrato que debe implementar la capa de datos
abstract class MovimientosRepository {
  /// Lista movimientos con filtros y paginación
  Future<MovimientosListEntity> getMovimientos({
    required int clienteId,
    int? productoId,
    int? proveedorId,
    TipoMovimiento? tipo,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    bool includeDeleted = false,
    int pageNumber = 1,
    int pageSize = 10,
  });

  /// Obtiene un movimiento por ID
  Future<MovimientoEntity> getMovimientoById({
    required int movimientoId,
    required int clienteId,
  });

  /// Crea un nuevo movimiento
  Future<MovimientoEntity> createMovimiento({
    required int productoId,
    required int usuarioId,
    required int clienteId,
    int? proveedorId,
    int? pagoId,
    int? cajaId,
    int? ventaId,
    required TipoMovimiento tipo,
    required double costo,
    required double impuesto,
    required double descuentoUnidad,
    required double cantidad,
    String? observacion,
    required DateTime fecha,
  });

  /// Actualiza un movimiento completo (PUT)
  Future<MovimientoEntity> updateMovimiento({
    required int movimientoId,
    required int productoId,
    required int usuarioId,
    required int clienteId,
    int? proveedorId,
    int? pagoId,
    int? cajaId,
    int? ventaId,
    required TipoMovimiento tipo,
    required double costo,
    required double impuesto,
    required double descuentoUnidad,
    required double cantidad,
    String? observacion,
    required DateTime fecha,
    required int updatedByUsuarioId,
  });

  /// Actualiza un movimiento parcialmente (PATCH)
  Future<MovimientoEntity> patchMovimiento({
    required int movimientoId,
    required int clienteId,
    int? productoId,
    int? usuarioId,
    int? proveedorId,
    int? pagoId,
    int? cajaId,
    int? ventaId,
    TipoMovimiento? tipo,
    double? costo,
    double? impuesto,
    double? descuentoUnidad,
    double? cantidad,
    String? observacion,
    DateTime? fecha,
    required int updatedByUsuarioId,
  });

  /// Elimina un movimiento (soft delete)
  Future<void> deleteMovimiento({
    required int movimientoId,
    required int clienteId,
    required int deletedByUsuarioId,
    String? deleteReason,
  });
}
