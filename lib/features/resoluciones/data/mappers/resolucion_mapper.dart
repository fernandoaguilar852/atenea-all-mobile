import '../../domain/entities/resolucion_entity.dart';
import '../models/resolucion_model.dart';

/// Mapper para convertir DTOs a Entities
class ResolucionMapper {
  /// Convierte ResolucionModel a ResolucionEntity
  static ResolucionEntity toEntity(ResolucionModel model) {
    return ResolucionEntity(
      resolucionId: model.resolucionId,
      clienteId: model.clienteId,
      prefijo: model.prefijo,
      numeroDesde: model.numeroDesde,
      numeroHasta: model.numeroHasta,
      numeroActual: model.numeroActual,
      numeroResolucion: model.numeroResolucion,
      fechaResolucion: DateTime.parse(model.fechaResolucion),
      fechaVencimiento: DateTime.parse(model.fechaVencimiento),
      activo: model.activo,
      createdAt: DateTime.parse(model.createdAt),
    );
  }

  /// Convierte lista de ResolucionModel a lista de ResolucionEntity
  static List<ResolucionEntity> toEntityList(List<ResolucionModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Convierte PaginacionModel a ResolucionesPaginacion
  static ResolucionesPaginacion? toPaginacionEntity(PaginacionModel? model) {
    if (model == null) return null;

    // Calcular totalPages basado en totalElement y pageSize
    final totalPages = (model.totalElement / model.pageSize).ceil();

    return ResolucionesPaginacion(
      currentPage: model.pageNumber,
      totalPages: totalPages,
      totalItems: model.totalElement,
      pageSize: model.pageSize,
      hasNext: model.hasMoreElements,
      hasPrevious: model.pageNumber > 1,
    );
  }

  /// Convierte ResolucionesResponse a ResolucionesListEntity
  static ResolucionesListEntity toListEntity(ResolucionesResponse response) {
    return ResolucionesListEntity(
      resoluciones: toEntityList(response.data.resoluciones),
      pagination: toPaginacionEntity(response.pagination),
    );
  }
}
