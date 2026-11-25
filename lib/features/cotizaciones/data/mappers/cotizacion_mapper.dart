import '../../domain/entities/cotizacion_detalle_entity.dart';
import '../../domain/entities/cotizacion_entity.dart';
import '../models/cotizacion_detalle_model.dart';
import '../models/cotizacion_model.dart';

/// Mapper para convertir DTOs a Entities
class CotizacionMapper {
  /// Convierte CotizacionModel a CotizacionEntity
  static CotizacionEntity toEntity(CotizacionModel model) {
    return CotizacionEntity(
      cotizacionId: model.cotizacionId,
      clienteId: model.clienteId,
      numeroCotizacion: model.numeroCotizacion,
      consumidorNombre: model.consumidor.nombre,
      consumidorIdentificacion: model.consumidor.identificacion,
      consumidorEmail: model.consumidor.email,
      consumidorTelefono: model.consumidor.telefono,
      fechaCotizacion: DateTime.parse(model.fechaCotizacion),
      fechaValidez: DateTime.parse(model.fechaValidez),
      diasValidez: model.diasValidez,
      estaVencida: model.estaVencida,
      total: model.totales.total,
      createdAt: DateTime.parse(model.createdAt),
    );
  }

  /// Convierte lista de CotizacionModel a lista de CotizacionEntity
  static List<CotizacionEntity> toEntityList(List<CotizacionModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Convierte PaginacionModel a CotizacionesPaginacion
  static CotizacionesPaginacion? toPaginacionEntity(PaginacionModel? model) {
    if (model == null) return null;

    // Calcular totalPages basado en totalElement y pageSize
    final totalPages = (model.totalElement / model.pageSize).ceil();

    return CotizacionesPaginacion(
      currentPage: model.pageNumber,
      totalPages: totalPages,
      totalItems: model.totalElement,
      pageSize: model.pageSize,
      hasNext: model.hasMoreElements,
      hasPrevious: model.pageNumber > 1,
    );
  }

  /// Convierte CotizacionesResponse a CotizacionesListEntity
  static CotizacionesListEntity toListEntity(CotizacionesResponse response) {
    return CotizacionesListEntity(
      cotizaciones: toEntityList(response.data.cotizaciones),
      pagination: toPaginacionEntity(response.pagination),
    );
  }

  /// Convierte CotizacionLineaModel a CotizacionLineaEntity
  static CotizacionLineaEntity toLineaEntity(CotizacionLineaModel model) {
    return CotizacionLineaEntity(
      cotizacionDetalleId: model.cotizacionDetalleId,
      productoId: model.productoId,
      nombreProducto: model.nombreProducto,
      descripcion: model.descripcion,
      cantidad: model.cantidad,
      precioUnitario: model.precioUnitario,
      subtotal: model.subtotal,
      descuentoValor: model.descuentoValor,
      valorImpuesto: model.valorImpuesto,
      totalLinea: model.totalLinea,
      observacionLinea: model.observacionLinea,
    );
  }

  /// Convierte CotizacionDetalleModel a CotizacionDetalleEntity
  /// De la auditoría solo se conserva el origen (no IP ni userAgent)
  static CotizacionDetalleEntity toDetalleEntity(CotizacionDetalleModel model) {
    return CotizacionDetalleEntity(
      cotizacionId: model.cotizacionId,
      clienteId: model.clienteId,
      numeroCotizacion: model.numeroCotizacion,
      consumidorNombre: model.consumidor.nombre,
      consumidorIdentificacion: model.consumidor.identificacion,
      consumidorEmail: model.consumidor.email,
      consumidorTelefono: model.consumidor.telefono,
      fechaCotizacion: DateTime.parse(model.fechaCotizacion),
      fechaValidez: DateTime.parse(model.fechaValidez),
      diasValidez: model.diasValidez,
      estaVencida: model.estaVencida,
      subtotalSinImpuestos: model.totales.subtotalSinImpuestos,
      totalDescuentos: model.totales.totalDescuentos,
      totalImpuestos: model.totales.totalImpuestos,
      total: model.totales.total,
      observacion: model.observacion,
      origen: model.auditoria?.origenRequest,
      createdAt: DateTime.parse(model.createdAt),
      updatedAt:
          model.updatedAt != null ? DateTime.parse(model.updatedAt!) : null,
      detalles: model.detalles.map(toLineaEntity).toList(),
    );
  }
}
