import '../../../../core/models/consumidor.dart';
import '../../domain/entities/consumidor_entity.dart';

/// Mapper para convertir los modelos globales de core a Entities
class ConsumidorMapper {
  /// Convierte Consumidor (core) a ConsumidorEntity
  static ConsumidorEntity toEntity(Consumidor model) {
    return ConsumidorEntity(
      consumidorId: model.consumidorId,
      clienteId: model.clienteId,
      tipoIdentificacion: model.tipoIdentificacion,
      numeroIdentificacion: model.numeroIdentificacion,
      digitoVerificacion: model.digitoVerificacion,
      nombreRazonSocial: model.nombreRazonSocial,
      direccion: model.direccion,
      email: model.email,
      telefono: model.telefono,
      ciudadId: model.ciudadId,
      activo: model.activo,
      creadoEn: DateTime.parse(model.creadoEn),
    );
  }

  /// Convierte lista de Consumidor a lista de ConsumidorEntity
  static List<ConsumidorEntity> toEntityList(List<Consumidor> models) {
    return models.map(toEntity).toList();
  }

  /// Convierte ConsumidorPagination a ConsumidoresPaginacion
  static ConsumidoresPaginacion? toPaginacionEntity(
    ConsumidorPagination? model,
  ) {
    if (model == null) return null;

    // Calcular totalPages basado en totalElement y pageSize
    final totalPages = (model.totalElement / model.pageSize).ceil();

    return ConsumidoresPaginacion(
      currentPage: model.pageNumber,
      totalPages: totalPages,
      totalItems: model.totalElement,
      pageSize: model.pageSize,
      hasNext: model.hasMoreElements,
      hasPrevious: model.pageNumber > 1,
    );
  }

  /// Convierte ConsumidorResponse a ConsumidoresListEntity
  static ConsumidoresListEntity toListEntity(ConsumidorResponse response) {
    return ConsumidoresListEntity(
      consumidores: toEntityList(response.data),
      pagination: toPaginacionEntity(response.pagination),
    );
  }
}
