import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../../core/providers/cache_provider.dart';
import '../../../../core/services/cache_service.dart';
import '../../data/datasources/ventas_remote_datasource.dart';
import '../../data/datasources/pagos_remote_datasource.dart';
import '../../data/datasources/consumidores_remote_datasource.dart';
import '../../data/repositories/ventas_repository_impl.dart';
import '../../domain/entities/venta_entity.dart';
import '../../domain/repositories/ventas_repository.dart';

// ============================================================================
// PROVIDERS DE INFRAESTRUCTURA
// ============================================================================

/// Provider del datasource remoto de ventas
final ventasRemoteDatasourceProvider = Provider<VentasRemoteDatasource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return VentasRemoteDatasource(dioClient.dio);
});

/// Provider del datasource remoto de pagos
final pagosRemoteDatasourceProvider = Provider<PagosRemoteDatasource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PagosRemoteDatasource(dioClient.dio);
});

/// Provider del datasource remoto de consumidores
final consumidoresRemoteDatasourceProvider = Provider<ConsumidoresRemoteDatasource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ConsumidoresRemoteDatasource(dioClient.dio);
});

/// Provider del repositorio
final ventasRepositoryProvider = Provider<VentasRepository>((ref) {
  final datasource = ref.watch(ventasRemoteDatasourceProvider);
  return VentasRepositoryImpl(datasource);
});

// ============================================================================
// STATE PROVIDER
// ============================================================================

/// Estado de la lista de ventas
class VentasState {
  final List<VentaEntity> ventas;
  final int totalElements;
  final bool hasMoreElements;
  final bool isLoading;
  final String? error;

  const VentasState({
    this.ventas = const [],
    this.totalElements = 0,
    this.hasMoreElements = false,
    this.isLoading = false,
    this.error,
  });

  VentasState copyWith({
    List<VentaEntity>? ventas,
    int? totalElements,
    bool? hasMoreElements,
    bool? isLoading,
    String? error,
  }) {
    return VentasState(
      ventas: ventas ?? this.ventas,
      totalElements: totalElements ?? this.totalElements,
      hasMoreElements: hasMoreElements ?? this.hasMoreElements,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier para gestionar el estado de ventas
class VentasNotifier extends StateNotifier<VentasState> {
  final VentasRepository _repository;
  final Ref _ref;

  VentasNotifier(this._repository, this._ref) : super(const VentasState());

  /// Genera una clave de cache única basada en los filtros
  String _getCacheKey({
    required int clienteId,
    required int pageNumber,
    required int pageSize,
    String? estado,
    int? cajaId,
    int? consumidorId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final startDateStr = startDate != null ? dateFormat.format(startDate) : 'null';
    final endDateStr = endDate != null ? dateFormat.format(endDate) : 'null';

    return CacheKeys.ventas(
      clienteId: clienteId,
      pageNumber: pageNumber,
      pageSize: pageSize,
      estado: estado ?? 'all',
      cajaId: cajaId ?? 0,
      consumidorId: consumidorId ?? 0,
      startDate: startDateStr,
      endDate: endDateStr,
    );
  }

  /// Carga la lista de ventas con filtros y cache (stale-while-revalidate)
  Future<void> loadVentas({
    required int clienteId,
    required int pageNumber,
    required int pageSize,
    String? estado,
    int? cajaId,
    int? consumidorId,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    try {
      final cacheService = _ref.read(cacheServiceProvider);
      final cacheKey = _getCacheKey(
        clienteId: clienteId,
        pageNumber: pageNumber,
        pageSize: pageSize,
        estado: estado,
        cajaId: cajaId,
        consumidorId: consumidorId,
        startDate: startDate,
        endDate: endDate,
      );

      // Paso 1: Cargar cache inmediatamente (RÁPIDO ⚡)
      if (!forceRefresh) {
        final cachedData = await cacheService.getStale<Map<String, dynamic>>(cacheKey);
        if (cachedData != null) {
          try {
            // Parsear datos cached (solo IDs y datos básicos)
            final totalElements = cachedData['totalElements'] as int;
            final hasMoreElements = cachedData['hasMoreElements'] as bool;

            // Mostrar loading con datos parciales
            state = state.copyWith(
              totalElements: totalElements,
              hasMoreElements: hasMoreElements,
              isLoading: true, // Sigue cargando en background
              error: null,
            );
            debugPrint('Cache hit for ventas (showing fresh data will load...)');
          } catch (e) {
            debugPrint('Error parsing cached ventas: $e');
          }
        } else {
          // No hay cache, mostrar loading completo
          state = state.copyWith(isLoading: true, error: null);
        }
      } else {
        state = state.copyWith(isLoading: true, error: null);
      }

      // Paso 2: Fetch datos frescos en background
      final result = await _repository.getVentas(
        clienteId: clienteId,
        pageNumber: pageNumber,
        pageSize: pageSize,
        estado: estado,
        cajaId: cajaId,
        consumidorId: consumidorId,
        startDate: startDate,
        endDate: endDate,
      );

      // Paso 3: Guardar en cache y actualizar UI
      await cacheService.set(
        key: cacheKey,
        data: {
          'totalElements': result.totalElements,
          'hasMoreElements': result.hasMoreElements,
        },
        duration: const Duration(minutes: 2), // Cache por 2 minutos (datos pueden cambiar desde PC)
      );

      state = state.copyWith(
        ventas: result.ventas,
        totalElements: result.totalElements,
        hasMoreElements: result.hasMoreElements,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Error loading ventas: $e');

      // Si hay datos cached, mantenerlos y solo mostrar error
      if (state.ventas.isNotEmpty) {
        state = state.copyWith(isLoading: false, error: 'Error al actualizar');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Error al cargar ventas: ${e.toString()}',
        );
      }
    }
  }

  /// Limpia todo el cache de ventas de un cliente
  Future<void> clearCache(int clienteId) async {
    try {
      final cacheService = _ref.read(cacheServiceProvider);
      await cacheService.clearByPattern(CacheKeys.ventasPrefix(clienteId));
      debugPrint('Cache de ventas limpiado para cliente $clienteId');
    } catch (e) {
      debugPrint('Error clearing ventas cache: $e');
    }
  }

  /// Anula una venta y limpia el cache
  Future<bool> anularVenta({
    required int clienteId,
    required int ventaId,
    required int usuarioId,
    String? motivoAnulacion,
  }) async {
    try {
      await _repository.anularVenta(
        clienteId: clienteId,
        ventaId: ventaId,
        usuarioId: usuarioId,
        motivoAnulacion: motivoAnulacion,
      );

      // Limpiar cache de ventas para forzar recarga de datos actualizados
      await clearCache(clienteId);

      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Error al anular venta: ${e.toString()}',
      );
      return false;
    }
  }

  /// Limpia el error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider principal de ventas
final ventasProvider = StateNotifierProvider<VentasNotifier, VentasState>((ref) {
  final repository = ref.watch(ventasRepositoryProvider);
  return VentasNotifier(repository, ref);
});
