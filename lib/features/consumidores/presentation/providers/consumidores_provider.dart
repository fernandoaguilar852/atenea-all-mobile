import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/cache_provider.dart';
import '../../../../core/providers/catalogs_providers.dart';
import '../../../../core/services/cache_service.dart';
import '../../data/repositories/consumidores_repository_impl.dart';
import '../../domain/entities/consumidor_entity.dart';
import '../../domain/repositories/consumidores_repository.dart';

// ============================================================================
// PROVIDERS DE INFRAESTRUCTURA
// ============================================================================

/// Provider del repositorio (usa el datasource global de consumidores)
final consumidoresRepositoryProvider = Provider<ConsumidoresRepository>((ref) {
  final datasource = ref.watch(consumidorDatasourceProvider);
  return ConsumidoresRepositoryImpl(datasource);
});

// ============================================================================
// STATE PROVIDER
// ============================================================================

/// Estado de la lista de consumidores
class ConsumidoresState {
  final ConsumidoresListEntity? data;
  final bool isLoading;
  final bool isLoadingMore; // Loading para paginación (no bloquea UI)
  final String? error;

  const ConsumidoresState({
    this.data,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  ConsumidoresState copyWith({
    ConsumidoresListEntity? data,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
  }) {
    return ConsumidoresState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

/// Notifier para gestionar el estado de consumidores
class ConsumidoresNotifier extends StateNotifier<ConsumidoresState> {
  final ConsumidoresRepository _repository;
  final Ref _ref;

  ConsumidoresNotifier(this._repository, this._ref)
      : super(const ConsumidoresState());

  /// Genera una clave de cache única basada en la página y los filtros
  String _getCacheKey({
    required int clienteId,
    required int pageNumber,
    required int pageSize,
    String? search,
    bool? activo,
  }) {
    return CacheKeys.consumidoresLista(
      clienteId: clienteId,
      pageNumber: pageNumber,
      pageSize: pageSize,
      search: (search ?? '').trim().toLowerCase(),
      activo: activo == null ? 'all' : (activo ? 'active' : 'inactive'),
    );
  }

  /// Carga la lista de consumidores con cache (stale-while-revalidate)
  Future<void> loadConsumidores({
    required int clienteId,
    int pageNumber = 1,
    int pageSize = 10,
    String? search,
    bool? activo,
    bool forceRefresh = false,
  }) async {
    try {
      final cacheService = _ref.read(cacheServiceProvider);
      final cacheKey = _getCacheKey(
        clienteId: clienteId,
        pageNumber: pageNumber,
        pageSize: pageSize,
        search: search,
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
          debugPrint('Cache hit for consumidores (showing fresh data will load...)');
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
      final result = await _repository.getConsumidores(
        clienteId: clienteId,
        pageNumber: pageNumber,
        pageSize: pageSize,
        search: search,
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
      debugPrint('Error loading consumidores: $e');

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
          error: 'Error al cargar clientes: ${e.toString()}',
        );
      }
    }
  }

  /// Limpia todo el cache del listado de consumidores de un cliente
  Future<void> clearCache(int clienteId) async {
    try {
      final cacheService = _ref.read(cacheServiceProvider);
      await cacheService.clearByPattern(CacheKeys.consumidoresListaPrefix(clienteId));
      debugPrint('Cache de consumidores limpiado para cliente $clienteId');
    } catch (e) {
      debugPrint('Error clearing consumidores cache: $e');
    }
  }
}

/// Provider del estado de consumidores
final consumidoresProvider =
    StateNotifierProvider<ConsumidoresNotifier, ConsumidoresState>((ref) {
  final repository = ref.watch(consumidoresRepositoryProvider);
  return ConsumidoresNotifier(repository, ref);
});
