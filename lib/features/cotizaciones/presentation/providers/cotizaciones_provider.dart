import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../../core/providers/cache_provider.dart';
import '../../../../core/services/cache_service.dart';
import '../../data/datasources/cotizaciones_remote_datasource.dart';
import '../../data/repositories/cotizaciones_repository_impl.dart';
import '../../domain/entities/cotizacion_entity.dart';
import '../../domain/repositories/cotizaciones_repository.dart';

// ============================================================================
// PROVIDERS DE INFRAESTRUCTURA
// ============================================================================

/// Provider del datasource remoto
final cotizacionesRemoteDatasourceProvider =
    Provider<CotizacionesRemoteDatasource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CotizacionesRemoteDatasource(dioClient.dio);
});

/// Provider del repositorio
final cotizacionesRepositoryProvider = Provider<CotizacionesRepository>((ref) {
  final datasource = ref.watch(cotizacionesRemoteDatasourceProvider);
  return CotizacionesRepositoryImpl(datasource);
});

// ============================================================================
// STATE PROVIDER
// ============================================================================

/// Estado de la lista de cotizaciones
class CotizacionesState {
  final CotizacionesListEntity? data;
  final bool isLoading;
  final bool isLoadingMore; // Loading para paginación (no bloquea UI)
  final String? error;

  const CotizacionesState({
    this.data,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  CotizacionesState copyWith({
    CotizacionesListEntity? data,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
  }) {
    return CotizacionesState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

/// Notifier para gestionar el estado de cotizaciones
class CotizacionesNotifier extends StateNotifier<CotizacionesState> {
  final CotizacionesRepository _repository;
  final Ref _ref;

  CotizacionesNotifier(this._repository, this._ref)
      : super(const CotizacionesState());

  /// Genera una clave de cache única basada en los filtros
  String _getCacheKey({
    required int clienteId,
    required int pageNumber,
    required int pageSize,
  }) {
    return CacheKeys.cotizaciones(
      clienteId: clienteId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  /// Carga la lista de cotizaciones con cache (stale-while-revalidate)
  Future<void> loadCotizaciones({
    required int clienteId,
    int pageNumber = 1,
    int pageSize = 10,
    bool forceRefresh = false,
  }) async {
    try {
      final cacheService = _ref.read(cacheServiceProvider);
      final cacheKey = _getCacheKey(
        clienteId: clienteId,
        pageNumber: pageNumber,
        pageSize: pageSize,
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
          debugPrint('Cache hit for cotizaciones (showing fresh data will load...)');
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
      final result = await _repository.getCotizaciones(
        clienteId: clienteId,
        pageNumber: pageNumber,
        pageSize: pageSize,
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
      debugPrint('Error loading cotizaciones: $e');

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
          error: 'Error al cargar cotizaciones: ${e.toString()}',
        );
      }
    }
  }

  /// Limpia todo el cache de cotizaciones de un cliente
  Future<void> clearCache(int clienteId) async {
    try {
      final cacheService = _ref.read(cacheServiceProvider);
      await cacheService.clearByPattern(CacheKeys.cotizacionesPrefix(clienteId));
      debugPrint('Cache de cotizaciones limpiado para cliente $clienteId');
    } catch (e) {
      debugPrint('Error clearing cotizaciones cache: $e');
    }
  }
}

/// Provider del estado de cotizaciones
final cotizacionesProvider =
    StateNotifierProvider<CotizacionesNotifier, CotizacionesState>((ref) {
  final repository = ref.watch(cotizacionesRepositoryProvider);
  return CotizacionesNotifier(repository, ref);
});
