import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../domain/entities/notificacion_entity.dart';
import '../../domain/repositories/notificaciones_repository.dart';
import '../../data/datasources/notificaciones_remote_datasource.dart';
import '../../data/repositories/notificaciones_repository_impl.dart';

/// Provider del datasource
final notificacionesRemoteDatasourceProvider = Provider<NotificacionesRemoteDatasource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return NotificacionesRemoteDatasource(dioClient.dio);
});

/// Provider del repository
final notificacionesRepositoryProvider = Provider<NotificacionesRepository>((ref) {
  final datasource = ref.watch(notificacionesRemoteDatasourceProvider);
  return NotificacionesRepositoryImpl(datasource);
});

/// Estado de la lista de notificaciones
class NotificacionesState {
  final List<NotificacionEntity> notificaciones;
  final bool isLoading;
  final String? error;
  final int totalElement;
  final int pageSize;
  final int pageNumber;
  final bool hasMoreElements;

  const NotificacionesState({
    this.notificaciones = const [],
    this.isLoading = false,
    this.error,
    this.totalElement = 0,
    this.pageSize = 10,
    this.pageNumber = 1,
    this.hasMoreElements = false,
  });

  NotificacionesState copyWith({
    List<NotificacionEntity>? notificaciones,
    bool? isLoading,
    String? error,
    int? totalElement,
    int? pageSize,
    int? pageNumber,
    bool? hasMoreElements,
  }) {
    return NotificacionesState(
      notificaciones: notificaciones ?? this.notificaciones,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalElement: totalElement ?? this.totalElement,
      pageSize: pageSize ?? this.pageSize,
      pageNumber: pageNumber ?? this.pageNumber,
      hasMoreElements: hasMoreElements ?? this.hasMoreElements,
    );
  }
}

/// Notifier para manejar el estado de notificaciones
class NotificacionesNotifier extends StateNotifier<NotificacionesState> {
  final NotificacionesRepository _repository;
  final int clienteId;

  NotificacionesNotifier(this._repository, this.clienteId)
      : super(const NotificacionesState());

  /// Obtener notificaciones pendientes (para el badge)
  Future<void> fetchPendientes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.listNotificaciones(
        clienteId: clienteId,
        estado: 'PENDIENTE',
        pageSize: 10,
        pageNumber: 1,
      );

      state = state.copyWith(
        notificaciones: response.notificaciones,
        totalElement: response.totalElement,
        pageSize: response.pageSize,
        pageNumber: response.pageNumber,
        hasMoreElements: response.hasMoreElements,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Obtener notificaciones leídas
  Future<void> fetchLeidas() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.listNotificaciones(
        clienteId: clienteId,
        estado: 'LEIDA',
        pageSize: 10,
        pageNumber: 1,
      );

      state = state.copyWith(
        notificaciones: response.notificaciones,
        totalElement: response.totalElement,
        pageSize: response.pageSize,
        pageNumber: response.pageNumber,
        hasMoreElements: response.hasMoreElements,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Obtener todas las notificaciones con filtro opcional
  Future<void> fetchNotificaciones({String? estado}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.listNotificaciones(
        clienteId: clienteId,
        estado: estado,
        pageSize: 10,
        pageNumber: 1,
      );

      state = state.copyWith(
        notificaciones: response.notificaciones,
        totalElement: response.totalElement,
        pageSize: response.pageSize,
        pageNumber: response.pageNumber,
        hasMoreElements: response.hasMoreElements,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Marcar notificación como leída
  Future<void> marcarComoLeida(int notificacionId) async {
    try {
      await _repository.updateEstadoNotificacion(
        clienteId: clienteId,
        notificacionId: notificacionId,
        estado: 'LEIDA',
      );

      // Eliminar la notificación de la lista local
      final updatedList = state.notificaciones
          .where((n) => n.notificacionId != notificacionId)
          .toList();

      state = state.copyWith(
        notificaciones: updatedList,
        totalElement: state.totalElement - 1,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Archivar notificación
  Future<void> archivar(int notificacionId) async {
    try {
      await _repository.updateEstadoNotificacion(
        clienteId: clienteId,
        notificacionId: notificacionId,
        estado: 'ARCHIVADA',
      );

      // Eliminar la notificación de la lista local
      final updatedList = state.notificaciones
          .where((n) => n.notificacionId != notificacionId)
          .toList();

      state = state.copyWith(
        notificaciones: updatedList,
        totalElement: state.totalElement - 1,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Eliminar notificación
  Future<void> eliminar(int notificacionId) async {
    try {
      await _repository.deleteNotificacion(
        clienteId: clienteId,
        notificacionId: notificacionId,
      );

      // Eliminar la notificación de la lista local
      final updatedList = state.notificaciones
          .where((n) => n.notificacionId != notificacionId)
          .toList();

      state = state.copyWith(
        notificaciones: updatedList,
        totalElement: state.totalElement - 1,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

/// Provider del notifier (requiere clienteId del auth)
final notificacionesProvider = StateNotifierProvider.family<
    NotificacionesNotifier,
    NotificacionesState,
    int>((ref, clienteId) {
  final repository = ref.watch(notificacionesRepositoryProvider);
  return NotificacionesNotifier(repository, clienteId);
});
