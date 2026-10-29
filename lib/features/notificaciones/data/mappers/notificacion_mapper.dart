import '../../domain/entities/notificacion_entity.dart';
import '../../domain/repositories/notificaciones_repository.dart';
import '../models/notificacion_model.dart';

class NotificacionMapper {
  /// Convierte NotificacionModel a NotificacionEntity
  static NotificacionEntity toEntity(NotificacionModel model) {
    return NotificacionEntity(
      notificacionId: model.notificacionId,
      clienteId: model.clienteId,
      tipo: model.tipo,
      titulo: model.titulo,
      mensaje: model.mensaje,
      prioridad: model.prioridad,
      estado: model.estado,
      resolucionId: model.resolucionId,
      metadata: model.metadata,
      createdAt: DateTime.parse(model.createdAt),
      updatedAt: DateTime.parse(model.updatedAt),
      leidaAt: model.leidaAt != null ? DateTime.parse(model.leidaAt!) : null,
      archivadaAt:
          model.archivadaAt != null ? DateTime.parse(model.archivadaAt!) : null,
    );
  }

  /// Convierte lista de NotificacionModel a lista de NotificacionEntity
  static List<NotificacionEntity> toEntityList(List<NotificacionModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Convierte NotificacionesListResponse a NotificacionesResponse
  static NotificacionesResponse toNotificacionesResponse(
      NotificacionesListResponse response) {
    return NotificacionesResponse(
      notificaciones: toEntityList(response.data.notificaciones),
      totalElement: response.pagination?.totalElement ?? 0,
      pageSize: response.pagination?.pageSize ?? 10,
      pageNumber: response.pagination?.pageNumber ?? 1,
      hasMoreElements: response.pagination?.hasMoreElements ?? false,
    );
  }
}
