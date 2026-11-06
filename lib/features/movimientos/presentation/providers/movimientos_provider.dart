import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../../core/providers/cache_provider.dart';
import '../../../../core/services/cache_service.dart';
import '../../data/datasources/movimientos_remote_datasource.dart';
import '../../data/repositories/movimientos_repository_impl.dart';
import '../../domain/entities/movimiento_entity.dart';
import '../../domain/repositories/movimientos_repository.dart';

// ============================================================================
// PROVIDERS DE INFRAESTRUCTURA
// ============================================================================

/// Provider del datasource remoto
final movimientosRemoteDatasourceProvider =
    Provider<MovimientosRemoteDatasource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return MovimientosRemoteDatasource(dioClient.dio);
});

/// Provider del repositorio
final movimientosRepositoryProvider = Provider<MovimientosRepository>((ref) {
  final datasource = ref.watch(movimientosRemoteDatasourceProvider);
  return MovimientosRepositoryImpl(datasource);
});

// ============================================================================
// STATE PROVIDER
// ============================================================================

/// Estado de la lista de movimientos
class MovimientosState {
  final MovimientosListEntity? data;
  final bool isLoading;
  final bool isLoadingMore; // Loading para paginación (no bloquea UI)
  final String? error;

  const MovimientosState({
    this.data,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  MovimientosState copyWith({
    MovimientosListEntity? data,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
  }) {
    return MovimientosState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

/// Notifier para gestionar el estado de movimientos
class MovimientosNotifier extends StateNotifier<MovimientosState> {
  final MovimientosRepository _repository;
  final Ref _ref;

  MovimientosNotifier(this._repository, this._ref) : super(const MovimientosState());

  /// Genera una clave de cache única basada en los filtros
  String _getCacheKey({
    required int clienteId,
    required int pageNumber,
    required int pageSize,
    TipoMovimiento? tipo,
    int? productoId,
    int? proveedorId,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final startDateStr = fechaDesde != null ? dateFormat.format(fechaDesde) : 'null';
    final endDateStr = fechaHasta != null ? dateFormat.format(fechaHasta) : 'null';

    return CacheKeys.movimientos(
      clienteId: clienteId,
      pageNumber: pageNumber,
      pageSize: pageSize,
      tipo: tipo?.name ?? 'all',
      productoId: productoId ?? 0,
      proveedorId: proveedorId ?? 0,
      startDate: startDateStr,
      endDate: endDateStr,
    );
  }

  /// Carga la lista de movimientos con filtros y cache (stale-while-revalidate)
  Future<void> loadMovimientos({
    required int clienteId,
    int? productoId,
    int? proveedorId,
    TipoMovimiento? tipo,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    bool includeDeleted = false,
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
        tipo: tipo,
        productoId: productoId,
        proveedorId: proveedorId,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
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
          debugPrint('Cache hit for movimientos (showing fresh data will load...)');
        } else {
          // No hay cache
          state = state.copyWith(
            isLoadingMore: hasExistingData, // Mantener datos visibles si existen
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
      final result = await _repository.getMovimientos(
        clienteId: clienteId,
        productoId: productoId,
        proveedorId: proveedorId,
        tipo: tipo,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
        includeDeleted: includeDeleted,
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
        duration: const Duration(minutes: 2), // Cache por 2 minutos
      );

      state = state.copyWith(
        data: result,
        isLoading: false,
        isLoadingMore: false,
      );
    } catch (e) {
      debugPrint('Error loading movimientos: $e');

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
          error: 'Error al cargar movimientos: ${e.toString()}',
        );
      }
    }
  }

  /// Limpia todo el cache de movimientos de un cliente
  Future<void> clearCache(int clienteId) async {
    try {
      final cacheService = _ref.read(cacheServiceProvider);
      await cacheService.clearByPattern(CacheKeys.movimientosPrefix(clienteId));
      debugPrint('Cache de movimientos limpiado para cliente $clienteId');
    } catch (e) {
      debugPrint('Error clearing movimientos cache: $e');
    }
  }

  /// Crea un nuevo movimiento y limpia el cache
  Future<bool> createMovimiento({
    required int productoId,
    required int usuarioId,
    required int clienteId,
    int? proveedorId,
    int? pagoId,
    int? cajaId,
    int? ventaId,
    required TipoMovimiento tipo,
    required double costo,
    required double impuesto,
    required double descuentoUnidad,
    required double cantidad,
    String? observacion,
    required DateTime fecha,
  }) async {
    try {
      await _repository.createMovimiento(
        productoId: productoId,
        usuarioId: usuarioId,
        clienteId: clienteId,
        proveedorId: proveedorId,
        pagoId: pagoId,
        cajaId: cajaId,
        ventaId: ventaId,
        tipo: tipo,
        costo: costo,
        impuesto: impuesto,
        descuentoUnidad: descuentoUnidad,
        cantidad: cantidad,
        observacion: observacion,
        fecha: fecha,
      );

      // Limpiar cache de movimientos para forzar recarga de datos actualizados
      await clearCache(clienteId);

      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Error al crear movimiento: ${e.toString()}',
      );
      return false;
    }
  }

  /// Actualiza un movimiento completo (PUT) y limpia el cache
  Future<bool> updateMovimiento({
    required int movimientoId,
    required int productoId,
    required int usuarioId,
    required int clienteId,
    int? proveedorId,
    int? pagoId,
    int? cajaId,
    int? ventaId,
    required TipoMovimiento tipo,
    required double costo,
    required double impuesto,
    required double descuentoUnidad,
    required double cantidad,
    String? observacion,
    required DateTime fecha,
    required int updatedByUsuarioId,
  }) async {
    try {
      await _repository.updateMovimiento(
        movimientoId: movimientoId,
        productoId: productoId,
        usuarioId: usuarioId,
        clienteId: clienteId,
        proveedorId: proveedorId,
        pagoId: pagoId,
        cajaId: cajaId,
        ventaId: ventaId,
        tipo: tipo,
        costo: costo,
        impuesto: impuesto,
        descuentoUnidad: descuentoUnidad,
        cantidad: cantidad,
        observacion: observacion,
        fecha: fecha,
        updatedByUsuarioId: updatedByUsuarioId,
      );

      // Limpiar cache de movimientos para forzar recarga de datos actualizados
      await clearCache(clienteId);

      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Error al actualizar movimiento: ${e.toString()}',
      );
      return false;
    }
  }

  /// Actualiza un movimiento parcialmente (PATCH) y limpia el cache
  Future<bool> patchMovimiento({
    required int movimientoId,
    required int clienteId,
    int? productoId,
    int? usuarioId,
    int? proveedorId,
    int? pagoId,
    int? cajaId,
    int? ventaId,
    TipoMovimiento? tipo,
    double? costo,
    double? impuesto,
    double? descuentoUnidad,
    double? cantidad,
    String? observacion,
    DateTime? fecha,
    required int updatedByUsuarioId,
  }) async {
    try {
      await _repository.patchMovimiento(
        movimientoId: movimientoId,
        clienteId: clienteId,
        productoId: productoId,
        usuarioId: usuarioId,
        proveedorId: proveedorId,
        pagoId: pagoId,
        cajaId: cajaId,
        ventaId: ventaId,
        tipo: tipo,
        costo: costo,
        impuesto: impuesto,
        descuentoUnidad: descuentoUnidad,
        cantidad: cantidad,
        observacion: observacion,
        fecha: fecha,
        updatedByUsuarioId: updatedByUsuarioId,
      );

      // Limpiar cache de movimientos para forzar recarga de datos actualizados
      await clearCache(clienteId);

      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Error al actualizar movimiento: ${e.toString()}',
      );
      return false;
    }
  }

  /// Elimina un movimiento (soft delete) y limpia el cache
  Future<bool> deleteMovimiento({
    required int movimientoId,
    required int clienteId,
    required int deletedByUsuarioId,
    String? deleteReason,
  }) async {
    try {
      await _repository.deleteMovimiento(
        movimientoId: movimientoId,
        clienteId: clienteId,
        deletedByUsuarioId: deletedByUsuarioId,
        deleteReason: deleteReason,
      );

      // Limpiar cache de movimientos para forzar recarga de datos actualizados
      await clearCache(clienteId);

      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Error al eliminar movimiento: ${e.toString()}',
      );
      return false;
    }
  }
}

/// Provider del estado de movimientos
final movimientosProvider =
    StateNotifierProvider<MovimientosNotifier, MovimientosState>((ref) {
  final repository = ref.watch(movimientosRepositoryProvider);
  return MovimientosNotifier(repository, ref);
});
