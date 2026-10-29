import '../entities/notificacion_entity.dart';

/// Respuesta paginada de notificaciones
class NotificacionesResponse {
  final List<NotificacionEntity> notificaciones;
  final int totalElement;
  final int pageSize;
  final int pageNumber;
  final bool hasMoreElements;

  const NotificacionesResponse({
    required this.notificaciones,
    required this.totalElement,
    required this.pageSize,
    required this.pageNumber,
    required this.hasMoreElements,
  });
}

/// Repository de dominio para Notificaciones
abstract class NotificacionesRepository {
  /// GET /v1/pos/notificaciones - Lista notificaciones con paginación
  Future<NotificacionesResponse> listNotificaciones({
    required int clienteId,
    String? estado,
    int pageSize = 10,
    int pageNumber = 1,
  });

  /// GET /v1/pos/notificaciones/{id} - Obtiene notificación por ID
  Future<NotificacionEntity> getNotificacionById({
    required int clienteId,
    required int notificacionId,
  });

  /// GET /v1/pos/notificaciones/pendientes - Obtiene notificaciones pendientes
  Future<NotificacionesResponse> getNotificacionesPendientes({
    required int clienteId,
    int pageSize = 10,
    int pageNumber = 1,
  });

  /// PATCH /v1/pos/notificaciones/{id} - Actualiza estado de notificación
  Future<NotificacionEntity> updateEstadoNotificacion({
    required int clienteId,
    required int notificacionId,
    required String estado, // 'LEIDA' o 'ARCHIVADA'
  });

  /// DELETE /v1/pos/notificaciones/{id} - Elimina notificación
  Future<void> deleteNotificacion({
    required int clienteId,
    required int notificacionId,
  });
}
