import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../../core/providers/cache_provider.dart';
import '../../../../core/services/cache_service.dart';
import '../../data/datasources/resoluciones_remote_datasource.dart';
import '../../data/repositories/resoluciones_repository_impl.dart';
import '../../domain/entities/resolucion_entity.dart';
import '../../domain/repositories/resoluciones_repository.dart';

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
  final bool isLoadingMore; // Loading para paginación (no bloquea UI)
  final String? error;

  const ResolucionesState({
    this.data,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  ResolucionesState copyWith({
    ResolucionesListEntity? data,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
  }) {
    return ResolucionesState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

/// Notifier para gestionar el estado de resoluciones
class ResolucionesNotifier extends StateNotifier<ResolucionesState> {
  final ResolucionesRepository _repository;
  final Ref _ref;

  ResolucionesNotifier(this._repository, this._ref) : super(const ResolucionesState());

  /// Genera una clave de cache única basada en los filtros
  String _getCacheKey({
    required int clienteId,
    required int pageNumber,
    required int pageSize,
    bool? activo,
  }) {
    return CacheKeys.resoluciones(
      clienteId: clienteId,
      pageNumber: pageNumber,
      pageSize: pageSize,
      activo: activo == null ? 'all' : (activo ? 'active' : 'inactive'),
    );
  }

  /// Carga la lista de resoluciones con cache (stale-while-revalidate)
  Future<void> loadResoluciones({
    required int clienteId,
    int pageNumber = 1,
    int pageSize = 10,
    bool? activo,
    bool forceRefresh = false,
  }) async {
    try {
      final cacheService = _ref.read(cacheServiceProvider);
      final cacheKey = _getCacheKey(
        clienteId: clienteId,
        pageNumber: pageNumber,
        pageSize: pageSize,
        activo: activo,
      );

      // Determinar tipo de loading: si hay datos, usar isLoadingMore (no bloquea UI)
      final hasExistingData = state.data != null;

      // Paso 1: Mostrar estado de loading apropiado
      if (!forceRefresh) {
        final cachedData = await cacheService.getStale<Map<String, dynamic>>(cacheKey);
        if (cachedData != null) {
          // Hay cache, mantener datos actuales y cargar en background
          state = state.copyWith(
            isLoadingMore: hasExistingData,
            isLoading: !hasExistingData,
            error: null,
          );
          debugPrint('Cache hit for resoluciones (showing fresh data will load...)');
        } else {
          // No hay cache
          state = state.copyWith(
            isLoadingMore: hasExistingData,
            isLoading: !hasExistingData,
            error: null,
          );
        }
      } else {
        state = state.copyWith(
          isLoadingMore: hasExistingData,
          isLoading: !hasExistingData,
          error: null,
        );
      }

      // Paso 2: Fetch datos frescos
      final result = await _repository.getResoluciones(
        clienteId: clienteId,
        pageNumber: pageNumber,
        pageSize: pageSize,
        activo: activo,
      );

      // Paso 3: Guardar en cache y actualizar UI
      await cacheService.set(
        key: cacheKey,
        data: {
          'pagination': {
            'currentPage': result.pagination?.currentPage,
            'totalPages': result.pagination?.totalPages,
            'totalItems': result.pagination?.totalItems,
            'hasNext': result.pagination?.hasNext,
            'hasPrevious': result.pagination?.hasPrevious,
          },
        },
        duration: const Duration(minutes: 5), // Cache por 5 minutos
      );

      state = state.copyWith(
        data: result,
        isLoading: false,
        isLoadingMore: false,
      );
    } catch (e) {
      debugPrint('Error loading resoluciones: $e');

      // Si hay datos existentes, mantenerlos visibles y solo mostrar error suave
      if (state.data != null) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: 'Error al actualizar',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: 'Error al cargar resoluciones: ${e.toString()}',
        );
      }
    }
  }

  /// Limpia todo el cache de resoluciones de un cliente
  Future<void> clearCache(int clienteId) async {
    try {
      final cacheService = _ref.read(cacheServiceProvider);
      await cacheService.clearByPattern(CacheKeys.resolucionesPrefix(clienteId));
      debugPrint('Cache de resoluciones limpiado para cliente $clienteId');
    } catch (e) {
      debugPrint('Error clearing resoluciones cache: $e');
    }
  }

  /// Crea una nueva resolución y limpia el cache
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

      // Limpiar cache de resoluciones para forzar recarga de datos actualizados
      await clearCache(clienteId);

      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Error al crear resolución: ${e.toString()}',
      );
      return false;
    }
  }

  /// Actualiza una resolución y limpia el cache
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

      // Limpiar cache de resoluciones para forzar recarga de datos actualizados
      await clearCache(clienteId);

      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Error al actualizar resolución: ${e.toString()}',
      );
      return false;
    }
  }

  /// Elimina una resolución y limpia el cache
  Future<bool> deleteResolucion({
    required int resolucionId,
    required int clienteId,
  }) async {
    try {
      await _repository.deleteResolucion(
        resolucionId: resolucionId,
        clienteId: clienteId,
      );

      // Limpiar cache de resoluciones para forzar recarga de datos actualizados
      await clearCache(clienteId);

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
  return ResolucionesNotifier(repository, ref);
});
