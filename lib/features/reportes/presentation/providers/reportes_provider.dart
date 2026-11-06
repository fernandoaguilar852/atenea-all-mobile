import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../../core/providers/cache_provider.dart';
import '../../../../core/services/cache_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/reportes_remote_datasource.dart';
import '../../data/repositories/reportes_repository_impl.dart';
import '../../domain/entities/arqueo_entity.dart';
import '../../domain/entities/costo_beneficio_entity.dart';
import '../../domain/entities/inventario_entity.dart';
import '../../domain/entities/stock_entity.dart';
import '../../domain/entities/venta_detalle_entity.dart';
import '../../domain/entities/ventas_entity.dart';
import '../../domain/repositories/reportes_repository.dart';

// ============================================================================
// PROVIDERS DE REPOSITORIO Y DATASOURCE
// ============================================================================

/// Provider del datasource remoto
final reportesRemoteDatasourceProvider = Provider<ReportesRemoteDatasource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ReportesRemoteDatasource(dioClient.dio);
});

/// Provider del repositorio de reportes
/// Este es el punto de acceso para toda la lógica de datos de reportes
final reportesRepositoryProvider = Provider<ReportesRepository>((ref) {
  final remoteDatasource = ref.watch(reportesRemoteDatasourceProvider);
  return ReportesRepositoryImpl(remoteDatasource);
});

// ============================================================================
// STATE CLASSES
// ============================================================================

class ReporteState<T> {
  final T? data;
  final bool isLoading;
  final bool isLoadingMore; // Loading para paginación (no bloquea UI)
  final String? error;

  ReporteState({
    this.data,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  ReporteState<T> copyWith({
    T? data,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
  }) {
    return ReporteState<T>(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

// ============================================================================
// REPORTE VENTAS
// ============================================================================

class VentasNotifier extends StateNotifier<ReporteState<VentasEntity>> {
  final ReportesRepository _repository;
  final Ref _ref;

  VentasNotifier(this._repository, this._ref) : super(ReporteState());

  /// Genera una clave de cache única basada en los filtros
  String _getCacheKey({
    required String startDate,
    required String endDate,
    required int pageNumber,
    required int pageSize,
    int? productoId,
    int? categoriaId,
    int? cajaId,
    bool? incluirAnuladas,
  }) {
    return CacheKeys.reporteVentas(
      startDate: startDate,
      endDate: endDate,
      pageNumber: pageNumber,
      pageSize: pageSize,
      productoId: productoId ?? 0,
      categoriaId: categoriaId ?? 0,
      cajaId: cajaId ?? 0,
      incluirAnuladas: incluirAnuladas ?? false,
    );
  }

  Future<void> loadReporte({
    required String startDate,
    required String endDate,
    int? productoId,
    String? nombreProducto,
    int? consumidorId,
    int? categoriaId,
    int? cajaId,
    bool? incluirAnuladas,
    int pageNumber = 1,
    int pageSize = 10,
    bool forceRefresh = false,
  }) async {
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) throw Exception('Usuario no autenticado');

      final cacheService = _ref.read(cacheServiceProvider);
      final cacheKey = _getCacheKey(
        startDate: startDate,
        endDate: endDate,
        pageNumber: pageNumber,
        pageSize: pageSize,
        productoId: productoId,
        categoriaId: categoriaId,
        cajaId: cajaId,
        incluirAnuladas: incluirAnuladas,
      );

      // Determinar tipo de loading
      final hasExistingData = state.data != null;

      // Paso 1: Intentar cargar desde cache si no es force refresh
      if (!forceRefresh) {
        final cachedData = await cacheService.getStale<Map<String, dynamic>>(cacheKey);
        if (cachedData != null) {
          state = state.copyWith(
            isLoadingMore: hasExistingData,
            isLoading: !hasExistingData,
            error: null,
          );
          debugPrint('Cache hit for ventas reporte (loading fresh data...)');
        } else {
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
      final reporte = await _repository.getVentasReporte(
        clienteId: user.clienteId,
        startDate: startDate,
        endDate: endDate,
        productoId: productoId,
        nombreProducto: nombreProducto,
        consumidorId: consumidorId,
        categoriaId: categoriaId,
        cajaId: cajaId,
        incluirAnuladas: incluirAnuladas,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      // Paso 3: Guardar en cache
      await cacheService.set(
        key: cacheKey,
        data: {
          'pagination': {
            'currentPage': reporte.pagination?.currentPage,
            'totalPages': reporte.pagination?.totalPages,
            'hasNext': reporte.pagination?.hasNext,
            'hasPrevious': reporte.pagination?.hasPrevious,
          },
        },
        duration: const Duration(minutes: 5), // Cache por 5 minutos
      );

      state = state.copyWith(
        data: reporte,
        isLoading: false,
        isLoadingMore: false,
      );
    } catch (e, stackTrace) {
      debugPrint('Error loading ventas reporte: $e');
      debugPrint('Stack trace: $stackTrace');

      // Si hay datos existentes, mantenerlos
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
          error: 'Error al cargar reporte de ventas',
        );
      }
    }
  }

  /// Limpia el cache de reportes de ventas
  Future<void> clearCache() async {
    try {
      final cacheService = _ref.read(cacheServiceProvider);
      await cacheService.clearByPattern(CacheKeys.reporteVentasPrefix);
      debugPrint('Cache de reportes de ventas limpiado');
    } catch (e) {
      debugPrint('Error clearing ventas reporte cache: $e');
    }
  }

  void clear() {
    state = ReporteState();
  }
}

final ventasReporteProvider =
    StateNotifierProvider<VentasNotifier, ReporteState<VentasEntity>>((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return VentasNotifier(repository, ref);
});

// ============================================================================
// REPORTE VENTA DETALLE
// ============================================================================

class VentaDetalleNotifier
    extends StateNotifier<ReporteState<VentaDetalleEntity>> {
  final ReportesRepository _repository;
  final Ref _ref;

  VentaDetalleNotifier(this._repository, this._ref) : super(ReporteState());

  Future<void> loadReporte({
    String? startDate,
    String? endDate,
    int? consumidorId,
    String? estado,
    int? productoId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) throw Exception('Usuario no autenticado');

      final reporte = await _repository.getVentaDetalleReporte(
        clienteId: user.clienteId,
        startDate: startDate,
        endDate: endDate,
        consumidorId: consumidorId,
        estado: estado,
        productoId: productoId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      state = state.copyWith(data: reporte, isLoading: false);
    } catch (e, stackTrace) {
      debugPrint('Error loading venta detalle reporte: $e');
      debugPrint('Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar reporte de venta detallada',
      );
    }
  }

  void clear() {
    state = ReporteState();
  }
}

final ventaDetalleReporteProvider = StateNotifierProvider<VentaDetalleNotifier,
    ReporteState<VentaDetalleEntity>>((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return VentaDetalleNotifier(repository, ref);
});

// ============================================================================
// REPORTE INVENTARIO CONSUMIDO
// ============================================================================

class InventarioNotifier
    extends StateNotifier<ReporteState<InventarioEntity>> {
  final ReportesRepository _repository;
  final Ref _ref;

  InventarioNotifier(this._repository, this._ref) : super(ReporteState());

  Future<void> loadReporte({
    required String startDate,
    required String endDate,
    int? productoId,
    String? tipoMovimiento,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) throw Exception('Usuario no autenticado');

      final reporte = await _repository.getInventarioReporte(
        clienteId: user.clienteId,
        startDate: startDate,
        endDate: endDate,
        productoId: productoId,
        tipoMovimiento: tipoMovimiento,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      state = state.copyWith(data: reporte, isLoading: false);
    } catch (e, stackTrace) {
      debugPrint('Error loading inventario reporte: $e');
      debugPrint('Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar reporte de inventario',
      );
    }
  }

  void clear() {
    state = ReporteState();
  }
}

final inventarioReporteProvider = StateNotifierProvider<InventarioNotifier,
    ReporteState<InventarioEntity>>((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return InventarioNotifier(repository, ref);
});

// ============================================================================
// REPORTE ARQUEO CAJA
// ============================================================================

class ArqueoNotifier extends StateNotifier<ReporteState<ArqueoEntity>> {
  final ReportesRepository _repository;
  final Ref _ref;

  ArqueoNotifier(this._repository, this._ref) : super(ReporteState());

  Future<void> loadReporte({
    required String startDate,
    required String endDate,
    int? cajaId,
    String? tipoPago,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) throw Exception('Usuario no autenticado');

      final reporte = await _repository.getArqueoReporte(
        clienteId: user.clienteId,
        startDate: startDate,
        endDate: endDate,
        cajaId: cajaId,
        tipoPago: tipoPago,
      );

      state = state.copyWith(data: reporte, isLoading: false);
    } catch (e, stackTrace) {
      debugPrint('Error loading arqueo reporte: $e');
      debugPrint('Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar arqueo de caja',
      );
    }
  }

  void clear() {
    state = ReporteState();
  }
}

final arqueoReporteProvider =
    StateNotifierProvider<ArqueoNotifier, ReporteState<ArqueoEntity>>((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return ArqueoNotifier(repository, ref);
});

// ============================================================================
// REPORTE STOCK PRODUCTOS
// ============================================================================

class StockNotifier extends StateNotifier<ReporteState<StockEntity>> {
  final ReportesRepository _repository;
  final Ref _ref;

  StockNotifier(this._repository, this._ref) : super(ReporteState());

  Future<void> loadReporte({
    int? productoId,
    bool? stockBajo,
    bool? activo,
    int? tipoProductoId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) throw Exception('Usuario no autenticado');

      final reporte = await _repository.getStockReporte(
        clienteId: user.clienteId,
        productoId: productoId,
        stockBajo: stockBajo,
        activo: activo,
        tipoProductoId: tipoProductoId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      state = state.copyWith(data: reporte, isLoading: false);
    } catch (e, stackTrace) {
      debugPrint('Error loading stock reporte: $e');
      debugPrint('Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar reporte de stock',
      );
    }
  }

  void clear() {
    state = ReporteState();
  }
}

final stockReporteProvider =
    StateNotifierProvider<StockNotifier, ReporteState<StockEntity>>((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return StockNotifier(repository, ref);
});

// ============================================================================
// REPORTE COSTO-BENEFICIO
// ============================================================================

class CostoBeneficioNotifier
    extends StateNotifier<ReporteState<CostoBeneficioEntity>> {
  final ReportesRepository _repository;
  final Ref _ref;

  CostoBeneficioNotifier(this._repository, this._ref) : super(ReporteState());

  Future<void> loadReporte({
    required String startDate,
    required String endDate,
    int? productoId,
    int? categoriaId,
    bool? activo,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) throw Exception('Usuario no autenticado');

      final reporte = await _repository.getCostoBeneficioReporte(
        clienteId: user.clienteId,
        startDate: startDate,
        endDate: endDate,
        productoId: productoId,
        categoriaId: categoriaId,
        activo: activo,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      state = state.copyWith(data: reporte, isLoading: false);
    } catch (e, stackTrace) {
      debugPrint('Error loading costo-beneficio reporte: $e');
      debugPrint('Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar reporte de costo-beneficio',
      );
    }
  }

  void clear() {
    state = ReporteState();
  }
}

final costoBeneficioReporteProvider = StateNotifierProvider<
    CostoBeneficioNotifier, ReporteState<CostoBeneficioEntity>>((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return CostoBeneficioNotifier(repository, ref);
});
