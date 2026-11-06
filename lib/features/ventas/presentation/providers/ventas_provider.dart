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

/// Entry del cache en RAM con timestamp
class _CacheEntry {
  final VentasState state;
  final DateTime timestamp;

  _CacheEntry(this.state, this.timestamp);

  bool isExpired(Duration ttl) {
    return DateTime.now().difference(timestamp) > ttl;
  }
}

/// Notifier para gestionar el estado de ventas
class VentasNotifier extends StateNotifier<VentasState> {
  final VentasRepository _repository;
  final Ref _ref;

  // 🚀 Cache en memoria (RAM) con TTL - estilo Instagram/Facebook
  // Navegación instantánea entre páginas + auto-refresh cada 2 minutos
  final Map<String, _CacheEntry> _memoryCache = {};
  static const Duration _cacheTTL = Duration(minutes: 2);

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

  /// Carga la lista de ventas con filtros y cache con TTL
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

      // ⚡ PASO 1: Verificar cache en RAM con TTL
      if (!forceRefresh && _memoryCache.containsKey(cacheKey)) {
        final cacheEntry = _memoryCache[cacheKey]!;

        if (!cacheEntry.isExpired(_cacheTTL)) {
          // Cache válido (< 2 min) - INSTANTÁNEO ⚡
          debugPrint('✨ Ventas RAM cache HIT (${DateTime.now().difference(cacheEntry.timestamp).inSeconds}s) - Carga instantánea!');
          state = cacheEntry.state;
          return; // NO hacer petición al servidor
        } else {
          // Cache expirado (> 2 min) - necesita actualizar
          debugPrint('⏰ Ventas RAM cache EXPIRADO - Consultando servidor para datos frescos...');
        }
      } else {
        debugPrint('🌐 Ventas RAM cache MISS - Consultando servidor...');
      }

      // PASO 2: Cache expirado o no existe - consultar servidor
      state = state.copyWith(isLoading: true, error: null);

      // PASO 3: Fetch datos frescos del servidor
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

      // PASO 4: Crear nuevo state y guardar en RAM con timestamp
      final newState = state.copyWith(
        ventas: result.ventas,
        totalElements: result.totalElements,
        hasMoreElements: result.hasMoreElements,
        isLoading: false,
      );

      _memoryCache[cacheKey] = _CacheEntry(newState, DateTime.now());
      debugPrint('💾 Ventas guardado en RAM (Total páginas: ${_memoryCache.length}, TTL: ${_cacheTTL.inMinutes} min)');

      state = newState;
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
      // Limpiar cache en RAM
      _memoryCache.clear();
      debugPrint('🗑️ Ventas RAM cache limpiado');

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
