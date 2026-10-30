import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
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

  VentasNotifier(this._repository) : super(const VentasState());

  /// Carga la lista de ventas con filtros
  Future<void> loadVentas({
    required int clienteId,
    required int pageNumber,
    required int pageSize,
    String? estado,
    int? cajaId,
    int? consumidorId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
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

      state = state.copyWith(
        ventas: result.ventas,
        totalElements: result.totalElements,
        hasMoreElements: result.hasMoreElements,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar ventas: ${e.toString()}',
      );
    }
  }

  /// Anula una venta
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
  return VentasNotifier(repository);
});
