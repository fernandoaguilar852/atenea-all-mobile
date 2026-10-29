import '../../domain/entities/notificacion_entity.dart';
import '../../domain/repositories/notificaciones_repository.dart';
import '../datasources/notificaciones_remote_datasource.dart';
import '../mappers/notificacion_mapper.dart';

/// Implementación del Repository de Notificaciones
class NotificacionesRepositoryImpl implements NotificacionesRepository {
  final NotificacionesRemoteDatasource _remoteDatasource;

  NotificacionesRepositoryImpl(this._remoteDatasource);

  @override
  Future<NotificacionesResponse> listNotificaciones({
    required int clienteId,
    String? estado,
    int pageSize = 10,
    int pageNumber = 1,
  }) async {
    final response = await _remoteDatasource.listNotificaciones(
      clienteId: clienteId,
      estado: estado,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );

    return NotificacionMapper.toNotificacionesResponse(response);
  }

  @override
  Future<NotificacionEntity> getNotificacionById({
    required int clienteId,
    required int notificacionId,
  }) async {
    final model = await _remoteDatasource.getNotificacionById(
      clienteId: clienteId,
      notificacionId: notificacionId,
    );

    return NotificacionMapper.toEntity(model);
  }

  @override
  Future<NotificacionesResponse> getNotificacionesPendientes({
    required int clienteId,
    int pageSize = 10,
    int pageNumber = 1,
  }) async {
    final response = await _remoteDatasource.getNotificacionesPendientes(
      clienteId: clienteId,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );

    return NotificacionMapper.toNotificacionesResponse(response);
  }

  @override
  Future<NotificacionEntity> updateEstadoNotificacion({
    required int clienteId,
    required int notificacionId,
    required String estado,
  }) async {
    final model = await _remoteDatasource.updateEstadoNotificacion(
      clienteId: clienteId,
      notificacionId: notificacionId,
      estado: estado,
    );

    return NotificacionMapper.toEntity(model);
  }

  @override
  Future<void> deleteNotificacion({
    required int clienteId,
    required int notificacionId,
  }) async {
    await _remoteDatasource.deleteNotificacion(
      clienteId: clienteId,
      notificacionId: notificacionId,
    );
  }
}
