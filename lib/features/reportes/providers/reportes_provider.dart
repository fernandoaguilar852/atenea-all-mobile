import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/dio_provider.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../data/datasources/reportes_remote_datasource.dart';
import '../data/repositories/reportes_repository_impl.dart';
import '../domain/entities/arqueo_entity.dart';
import '../domain/entities/costo_beneficio_entity.dart';
import '../domain/entities/inventario_entity.dart';
import '../domain/entities/stock_entity.dart';
import '../domain/entities/venta_detalle_entity.dart';
import '../domain/entities/ventas_entity.dart';
import '../domain/repositories/reportes_repository.dart';

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
  final String? error;

  ReporteState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  ReporteState<T> copyWith({
    T? data,
    bool? isLoading,
    String? error,
  }) {
    return ReporteState<T>(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
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
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) throw Exception('Usuario no autenticado');

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

      state = state.copyWith(data: reporte, isLoading: false);
    } catch (e) {
      debugPrint('Error loading ventas reporte: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar reporte de ventas',
      );
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
    } catch (e) {
      debugPrint('Error loading venta detalle reporte: $e');
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
    ReporteState<VentaDetalleReporte>>((ref) {
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
    } catch (e) {
      debugPrint('Error loading inventario reporte: $e');
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
    ReporteState<InventarioReporte>>((ref) {
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
    } catch (e) {
      debugPrint('Error loading arqueo reporte: $e');
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
    String? nombreProducto,
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
        nombreProducto: nombreProducto,
        stockBajo: stockBajo,
        activo: activo,
        tipoProductoId: tipoProductoId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      state = state.copyWith(data: reporte, isLoading: false);
    } catch (e) {
      debugPrint('Error loading stock reporte: $e');
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
    } catch (e) {
      debugPrint('Error loading costo-beneficio reporte: $e');
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
    CostoBeneficioNotifier, ReporteState<CostoBeneficioReporte>>((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return CostoBeneficioNotifier(repository, ref);
});
