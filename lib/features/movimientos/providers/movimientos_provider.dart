import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/dio_provider.dart';
import '../data/datasources/movimientos_remote_datasource.dart';
import '../data/repositories/movimientos_repository_impl.dart';
import '../domain/entities/movimiento_entity.dart';
import '../domain/repositories/movimientos_repository.dart';

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
  final String? error;

  const MovimientosState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  MovimientosState copyWith({
    MovimientosListEntity? data,
    bool? isLoading,
    String? error,
  }) {
    return MovimientosState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier para gestionar el estado de movimientos
class MovimientosNotifier extends StateNotifier<MovimientosState> {
  final MovimientosRepository _repository;

  MovimientosNotifier(this._repository) : super(const MovimientosState());

  /// Carga la lista de movimientos con filtros
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
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
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

      state = state.copyWith(
        data: result,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar movimientos: ${e.toString()}',
      );
    }
  }

  /// Crea un nuevo movimiento
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
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Error al crear movimiento: ${e.toString()}',
      );
      return false;
    }
  }

  /// Actualiza un movimiento completo (PUT)
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
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Error al actualizar movimiento: ${e.toString()}',
      );
      return false;
    }
  }

  /// Actualiza un movimiento parcialmente (PATCH)
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
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Error al actualizar movimiento: ${e.toString()}',
      );
      return false;
    }
  }

  /// Elimina un movimiento (soft delete)
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
  return MovimientosNotifier(repository);
});
