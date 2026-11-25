import '../../domain/entities/cotizacion_entity.dart';
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
}
