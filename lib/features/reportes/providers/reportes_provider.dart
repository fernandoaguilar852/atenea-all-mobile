import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/providers/dio_provider.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../data/models/arqueo_reporte.dart';
import '../data/models/costo_beneficio_reporte.dart';
import '../data/models/inventario_reporte.dart';
import '../data/models/stock_reporte.dart';
import '../data/models/venta_detalle_reporte.dart';
import '../data/models/ventas_reporte.dart';

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

class VentasNotifier extends StateNotifier<ReporteState<VentasReporte>> {
  final Dio _dio;
  final Ref _ref;

  VentasNotifier(this._dio, this._ref) : super(ReporteState());

  Future<void> loadReporte({
    required String startDate,
    required String endDate,
    String? nombreProducto,
    int? categoriaId,
    int? cajaId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) throw Exception('Usuario no autenticado');

      final queryParams = {
        'clienteId': user.clienteId,
        'startDate': startDate,
        'endDate': endDate,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };

      if (nombreProducto != null && nombreProducto.isNotEmpty) {
        queryParams['nombreProducto'] = nombreProducto;
      }
      if (categoriaId != null) {
        queryParams['categoriaId'] = categoriaId;
      }
      if (cajaId != null) {
        queryParams['cajaId'] = cajaId;
      }

      final response = await _dio.get(
        ApiConstants.buildUrl(ApiConstants.reporteVentas),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final reporte = VentasReporte.fromJson(response.data['data']);
        state = state.copyWith(data: reporte, isLoading: false);
      } else {
        throw Exception('Error al obtener reporte de ventas');
      }
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
    StateNotifierProvider<VentasNotifier, ReporteState<VentasReporte>>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return VentasNotifier(dioClient.dio, ref);
});

// ============================================================================
// REPORTE VENTA DETALLE
// ============================================================================

class VentaDetalleNotifier
    extends StateNotifier<ReporteState<VentaDetalleReporte>> {
  final Dio _dio;
  final Ref _ref;

  VentaDetalleNotifier(this._dio, this._ref) : super(ReporteState());

  Future<void> loadReporte({
    required String startDate,
    required String endDate,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) throw Exception('Usuario no autenticado');

      final response = await _dio.get(
        ApiConstants.buildUrl(ApiConstants.reporteVentaDetalle),
        queryParameters: {
          'clienteId': user.clienteId,
          'startDate': startDate,
          'endDate': endDate,
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final reporte = VentaDetalleReporte.fromJson(response.data['data']);
        state = state.copyWith(data: reporte, isLoading: false);
      } else {
        throw Exception('Error al obtener reporte de venta detallada');
      }
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
  final dioClient = ref.watch(dioClientProvider);
  return VentaDetalleNotifier(dioClient.dio, ref);
});

// ============================================================================
// REPORTE INVENTARIO CONSUMIDO
// ============================================================================

class InventarioNotifier
    extends StateNotifier<ReporteState<InventarioReporte>> {
  final Dio _dio;
  final Ref _ref;

  InventarioNotifier(this._dio, this._ref) : super(ReporteState());

  Future<void> loadReporte({
    required String startDate,
    required String endDate,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) throw Exception('Usuario no autenticado');

      final response = await _dio.get(
        ApiConstants.buildUrl(ApiConstants.reporteInventarioConsumido),
        queryParameters: {
          'clienteId': user.clienteId,
          'startDate': startDate,
          'endDate': endDate,
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final reporte = InventarioReporte.fromJson(response.data['data']);
        state = state.copyWith(data: reporte, isLoading: false);
      } else {
        throw Exception('Error al obtener reporte de inventario');
      }
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
  final dioClient = ref.watch(dioClientProvider);
  return InventarioNotifier(dioClient.dio, ref);
});

// ============================================================================
// REPORTE ARQUEO CAJA
// ============================================================================

class ArqueoNotifier extends StateNotifier<ReporteState<ArqueoReporte>> {
  final Dio _dio;
  final Ref _ref;

  ArqueoNotifier(this._dio, this._ref) : super(ReporteState());

  Future<void> loadReporte({
    required String startDate,
    required String endDate,
    int? cajaId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) throw Exception('Usuario no autenticado');

      final queryParams = {
        'clienteId': user.clienteId,
        'startDate': startDate,
        'endDate': endDate,
      };

      if (cajaId != null) {
        queryParams['cajaId'] = cajaId;
      }

      final response = await _dio.get(
        ApiConstants.buildUrl(ApiConstants.reporteArqueoCaja),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final reporte = ArqueoReporte.fromJson(response.data['data']);
        state = state.copyWith(data: reporte, isLoading: false);
      } else {
        throw Exception('Error al obtener arqueo de caja');
      }
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
    StateNotifierProvider<ArqueoNotifier, ReporteState<ArqueoReporte>>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ArqueoNotifier(dioClient.dio, ref);
});

// ============================================================================
// REPORTE STOCK PRODUCTOS
// ============================================================================

class StockNotifier extends StateNotifier<ReporteState<StockReporte>> {
  final Dio _dio;
  final Ref _ref;

  StockNotifier(this._dio, this._ref) : super(ReporteState());

  Future<void> loadReporte({
    bool? activo,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) throw Exception('Usuario no autenticado');

      final queryParams = <String, dynamic>{
        'clienteId': user.clienteId,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };

      if (activo != null) {
        queryParams['activo'] = activo;
      }

      final response = await _dio.get(
        ApiConstants.buildUrl(ApiConstants.reporteStockProductos),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final reporte = StockReporte.fromJson(response.data['data']);
        state = state.copyWith(data: reporte, isLoading: false);
      } else {
        throw Exception('Error al obtener reporte de stock');
      }
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
    StateNotifierProvider<StockNotifier, ReporteState<StockReporte>>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return StockNotifier(dioClient.dio, ref);
});

// ============================================================================
// REPORTE COSTO-BENEFICIO
// ============================================================================

class CostoBeneficioNotifier
    extends StateNotifier<ReporteState<CostoBeneficioReporte>> {
  final Dio _dio;
  final Ref _ref;

  CostoBeneficioNotifier(this._dio, this._ref) : super(ReporteState());

  Future<void> loadReporte({
    required String startDate,
    required String endDate,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) throw Exception('Usuario no autenticado');

      final response = await _dio.get(
        ApiConstants.buildUrl(ApiConstants.reporteCostoBeneficio),
        queryParameters: {
          'clienteId': user.clienteId,
          'startDate': startDate,
          'endDate': endDate,
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final reporte = CostoBeneficioReporte.fromJson(response.data['data']);
        state = state.copyWith(data: reporte, isLoading: false);
      } else {
        throw Exception('Error al obtener reporte de costo-beneficio');
      }
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
  final dioClient = ref.watch(dioClientProvider);
  return CostoBeneficioNotifier(dioClient.dio, ref);
});
