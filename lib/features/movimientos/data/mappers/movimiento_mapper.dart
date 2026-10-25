import '../../domain/entities/movimiento_entity.dart';
import '../models/movimiento_model.dart';

/// Mapper para convertir DTOs a Entities
class MovimientoMapper {
  /// Convierte MovimientoModel a MovimientoEntity
  static MovimientoEntity toEntity(MovimientoModel model) {
    return MovimientoEntity(
      movimientoId: model.movimientoId,
      productoId: model.productoId,
      nombreProducto: model.nombreProducto,
      usuarioId: model.usuarioId,
      clienteId: model.clienteId,
      proveedorId: model.proveedorId,
      cajaId: model.cajaId,
      pagoId: model.pagoId,
      ventaId: model.ventaId,
      tipo: _parseTipoMovimiento(model.tipo),
      costo: _parseDouble(model.costo),
      impuesto: _parseDouble(model.impuesto),
      descuentoUnidad: _parseDouble(model.descuentoUnidad),
      cantidad: _parseDouble(model.cantidad),
      observacion: model.observacion,
      fecha: DateTime.parse(model.fecha),
      createdAt: DateTime.parse(model.createdAt),
      updatedAt: model.updatedAt != null ? DateTime.parse(model.updatedAt!) : null,
      updatedByUsuarioId: model.updatedByUsuarioId,
      deletedAt: model.deletedAt != null ? DateTime.parse(model.deletedAt!) : null,
      deletedByUsuarioId: model.deletedByUsuarioId,
      deleteReason: model.deleteReason,
    );
  }

  /// Parse dynamic a double (maneja null, int, double, string)
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Convierte lista de MovimientoModel a lista de MovimientoEntity
  static List<MovimientoEntity> toEntityList(List<MovimientoModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Convierte PaginacionModel a MovimientosPaginacion
  static MovimientosPaginacion? toPaginacionEntity(PaginacionModel? model) {
    if (model == null) return null;

    // Calcular totalPages basado en totalElement y pageSize
    final totalPages = (model.totalElement / model.pageSize).ceil();

    return MovimientosPaginacion(
      currentPage: model.pageNumber,
      totalPages: totalPages,
      totalItems: model.totalElement,
      pageSize: model.pageSize,
      hasNext: model.hasMoreElements,
      hasPrevious: model.pageNumber > 1,
    );
  }

  /// Convierte MovimientosResponse a MovimientosListEntity
  static MovimientosListEntity toListEntity(MovimientosResponse response) {
    return MovimientosListEntity(
      movimientos: toEntityList(response.data.movimientos),
      pagination: toPaginacionEntity(response.pagination),
    );
  }

  /// Parse string a TipoMovimiento enum
  static TipoMovimiento _parseTipoMovimiento(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'entrada':
        return TipoMovimiento.entrada;
      case 'salida':
        return TipoMovimiento.salida;
      case 'venta':
        return TipoMovimiento.venta;
      case 'ajuste':
        return TipoMovimiento.ajuste;
      case 'merma':
        return TipoMovimiento.merma;
      case 'ingreso':
        return TipoMovimiento.ingreso;
      case 'egreso':
        return TipoMovimiento.egreso;
      default:
        throw Exception('Tipo de movimiento desconocido: $tipo');
    }
  }

  /// Convierte TipoMovimiento enum a string
  static String tipoMovimientoToString(TipoMovimiento tipo) {
    return tipo.name;
  }
}
