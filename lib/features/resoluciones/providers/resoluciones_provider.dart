import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/dio_provider.dart';
import '../data/datasources/resoluciones_remote_datasource.dart';
import '../data/repositories/resoluciones_repository_impl.dart';
import '../domain/entities/resolucion_entity.dart';
import '../domain/repositories/resoluciones_repository.dart';

// ============================================================================
// PROVIDERS DE INFRAESTRUCTURA
// ============================================================================

/// Provider del datasource remoto
final resolucionesRemoteDatasourceProvider =
    Provider<ResolucionesRemoteDatasource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ResolucionesRemoteDatasource(dioClient.dio);
});

/// Provider del repositorio
final resolucionesRepositoryProvider = Provider<ResolucionesRepository>((ref) {
  final datasource = ref.watch(resolucionesRemoteDatasourceProvider);
  return ResolucionesRepositoryImpl(datasource);
});

// ============================================================================
// STATE PROVIDER
// ============================================================================

/// Estado de la lista de resoluciones
class ResolucionesState {
  final ResolucionesListEntity? data;
  final bool isLoading;
  final String? error;

  const ResolucionesState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  ResolucionesState copyWith({
    ResolucionesListEntity? data,
    bool? isLoading,
    String? error,
  }) {
    return ResolucionesState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier para gestionar el estado de resoluciones
class ResolucionesNotifier extends StateNotifier<ResolucionesState> {
  final ResolucionesRepository _repository;

  ResolucionesNotifier(this._repository) : super(const ResolucionesState());

  /// Carga la lista de resoluciones
  Future<void> loadResoluciones({
    required int clienteId,
    int pageNumber = 1,
    int pageSize = 10,
    bool? activo,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.getResoluciones(
        clienteId: clienteId,
        pageNumber: pageNumber,
        pageSize: pageSize,
        activo: activo,
      );

      state = state.copyWith(
        data: result,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar resoluciones: ${e.toString()}',
      );
    }
  }

  /// Crea una nueva resolución
  Future<bool> createResolucion({
    required int clienteId,
    required String prefijo,
    required int numeroDesde,
    required int numeroHasta,
    required int numeroActual,
    required String numeroResolucion,
    required DateTime fechaResolucion,
    required DateTime fechaVencimiento,
    required bool activo,
  }) async {
    try {
      await _repository.createResolucion(
        clienteId: clienteId,
        prefijo: prefijo,
        numeroDesde: numeroDesde,
        numeroHasta: numeroHasta,
        numeroActual: numeroActual,
        numeroResolucion: numeroResolucion,
        fechaResolucion: fechaResolucion,
        fechaVencimiento: fechaVencimiento,
        activo: activo,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Error al crear resolución: ${e.toString()}',
      );
      return false;
    }
  }

  /// Actualiza una resolución
  Future<bool> updateResolucion({
    required int resolucionId,
    required int clienteId,
    required String prefijo,
    required int numeroHasta,
    required int numeroActual,
    required DateTime fechaVencimiento,
    required bool activo,
  }) async {
    try {
      await _repository.updateResolucion(
        resolucionId: resolucionId,
        clienteId: clienteId,
        prefijo: prefijo,
        numeroHasta: numeroHasta,
        numeroActual: numeroActual,
        fechaVencimiento: fechaVencimiento,
        activo: activo,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Error al actualizar resolución: ${e.toString()}',
      );
      return false;
    }
  }

  /// Elimina una resolución
  Future<bool> deleteResolucion({
    required int resolucionId,
    required int clienteId,
  }) async {
    try {
      await _repository.deleteResolucion(
        resolucionId: resolucionId,
        clienteId: clienteId,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Error al eliminar resolución: ${e.toString()}',
      );
      return false;
    }
  }
}

/// Provider del estado de resoluciones
final resolucionesProvider =
    StateNotifierProvider<ResolucionesNotifier, ResolucionesState>((ref) {
  final repository = ref.watch(resolucionesRepositoryProvider);
  return ResolucionesNotifier(repository);
});
