import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../domain/entities/alerta_stock_entity.dart';
import '../../domain/repositories/alertas_stock_repository.dart';
import '../../data/datasources/alertas_stock_remote_datasource.dart';
import '../../data/repositories/alertas_stock_repository_impl.dart';

/// Provider del datasource
final alertasStockRemoteDatasourceProvider =
    Provider<AlertasStockRemoteDatasource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AlertasStockRemoteDatasource(dioClient.dio);
});

/// Provider del repository
final alertasStockRepositoryProvider = Provider<AlertasStockRepository>((ref) {
  final datasource = ref.watch(alertasStockRemoteDatasourceProvider);
  return AlertasStockRepositoryImpl(datasource);
});

/// Estado de la lista de alertas de stock
class AlertasStockState {
  final List<AlertaStockEntity> alertas;
  final bool isLoading;
  final String? error;
  final int totalElement;
  final int pageSize;
  final int pageNumber;
  final bool hasMoreElements;

  const AlertasStockState({
    this.alertas = const [],
    this.isLoading = false,
    this.error,
    this.totalElement = 0,
    this.pageSize = 10,
    this.pageNumber = 1,
    this.hasMoreElements = false,
  });

  AlertasStockState copyWith({
    List<AlertaStockEntity>? alertas,
    bool? isLoading,
    String? error,
    int? totalElement,
    int? pageSize,
    int? pageNumber,
    bool? hasMoreElements,
  }) {
    return AlertasStockState(
      alertas: alertas ?? this.alertas,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalElement: totalElement ?? this.totalElement,
      pageSize: pageSize ?? this.pageSize,
      pageNumber: pageNumber ?? this.pageNumber,
      hasMoreElements: hasMoreElements ?? this.hasMoreElements,
    );
  }
}

/// Notifier para manejar el estado de alertas de stock
class AlertasStockNotifier extends StateNotifier<AlertasStockState> {
  final AlertasStockRepository _repository;
  final int clienteId;

  AlertasStockNotifier(this._repository, this.clienteId)
      : super(const AlertasStockState());

  /// Obtener alertas de stock
  Future<void> fetchAlertas({
    int pageNumber = 1,
    int? productoId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.listAlertasStock(
        clienteId: clienteId,
        pageSize: 10,
        pageNumber: pageNumber,
        productoId: productoId,
      );

      state = state.copyWith(
        alertas: response.alertas,
        totalElement: response.totalElement,
        pageSize: response.pageSize,
        pageNumber: response.pageNumber,
        hasMoreElements: response.hasMoreElements,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refrescar la lista desde la primera página
  Future<void> refresh() async {
    await fetchAlertas(pageNumber: 1);
  }
}

/// Provider del notifier (requiere clienteId del auth)
final alertasStockProvider = StateNotifierProvider.family<
    AlertasStockNotifier,
    AlertasStockState,
    int>((ref, clienteId) {
  final repository = ref.watch(alertasStockRepositoryProvider);
  return AlertasStockNotifier(repository, clienteId);
});
