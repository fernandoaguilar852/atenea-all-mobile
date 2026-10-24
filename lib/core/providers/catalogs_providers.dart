import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/caja_datasource.dart';
import '../datasources/consumidor_datasource.dart';
import '../datasources/producto_datasource.dart';
import '../datasources/tipo_producto_datasource.dart';
import '../models/caja.dart';
import '../models/consumidor.dart';
import '../models/producto.dart';
import '../models/tipo_producto.dart';
import 'dio_provider.dart';

// ============================================================================
// DATASOURCE PROVIDERS
// ============================================================================

final tipoProductoDatasourceProvider = Provider<TipoProductoDatasource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return TipoProductoDatasource(dioClient.dio);
});

final cajaDatasourceProvider = Provider<CajaDatasource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CajaDatasource(dioClient.dio);
});

final productoDatasourceProvider = Provider<ProductoDatasource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ProductoDatasource(dioClient.dio);
});

final consumidorDatasourceProvider = Provider<ConsumidorDatasource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ConsumidorDatasource(dioClient.dio);
});

// ============================================================================
// STATE PROVIDERS
// ============================================================================

/// Parámetros para provider de tipos de producto
class TiposProductoParams {
  final int clienteId;
  final int pageSize;

  const TiposProductoParams({
    required this.clienteId,
    this.pageSize = 100,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TiposProductoParams &&
          runtimeType == other.runtimeType &&
          clienteId == other.clienteId &&
          pageSize == other.pageSize;

  @override
  int get hashCode => clienteId.hashCode ^ pageSize.hashCode;
}

/// Parámetros para provider de cajas
class CajasParams {
  final int clienteId;
  final String? estado;
  final int pageSize;

  const CajasParams({
    required this.clienteId,
    this.estado,
    this.pageSize = 100,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CajasParams &&
          runtimeType == other.runtimeType &&
          clienteId == other.clienteId &&
          estado == other.estado &&
          pageSize == other.pageSize;

  @override
  int get hashCode => clienteId.hashCode ^ estado.hashCode ^ pageSize.hashCode;
}

/// Parámetros para búsqueda de productos
class ProductosSearchParams {
  final int clienteId;
  final String searchTerm;
  final int pageSize;

  const ProductosSearchParams({
    required this.clienteId,
    required this.searchTerm,
    this.pageSize = 20,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductosSearchParams &&
          runtimeType == other.runtimeType &&
          clienteId == other.clienteId &&
          searchTerm == other.searchTerm &&
          pageSize == other.pageSize;

  @override
  int get hashCode =>
      clienteId.hashCode ^ searchTerm.hashCode ^ pageSize.hashCode;
}

/// Parámetros para búsqueda de consumidores
class ConsumidoresSearchParams {
  final int clienteId;
  final String searchTerm;
  final int pageSize;

  const ConsumidoresSearchParams({
    required this.clienteId,
    required this.searchTerm,
    this.pageSize = 20,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsumidoresSearchParams &&
          runtimeType == other.runtimeType &&
          clienteId == other.clienteId &&
          searchTerm == other.searchTerm &&
          pageSize == other.pageSize;

  @override
  int get hashCode =>
      clienteId.hashCode ^ searchTerm.hashCode ^ pageSize.hashCode;
}

/// Provider para obtener lista de tipos de producto
/// Recibe clienteId como parámetro en lugar de depender de auth
final tiposProductoProvider =
    FutureProvider.family<List<TipoProducto>, TiposProductoParams>(
  (ref, params) async {
    final datasource = ref.watch(tipoProductoDatasourceProvider);
    return await datasource.getTiposProducto(
      clienteId: params.clienteId,
      pageSize: params.pageSize,
    );
  },
);

/// Provider para obtener lista de cajas
/// Recibe clienteId y estado como parámetros
final cajasProvider = FutureProvider.family<List<Caja>, CajasParams>(
  (ref, params) async {
    final datasource = ref.watch(cajaDatasourceProvider);
    return await datasource.getCajas(
      clienteId: params.clienteId,
      estado: params.estado,
      pageSize: params.pageSize,
    );
  },
);

/// Provider para buscar productos por nombre
/// Recibe clienteId y searchTerm como parámetros
final productosSearchProvider =
    FutureProvider.family<List<Producto>, ProductosSearchParams>(
  (ref, params) async {
    if (params.searchTerm.length < 3) return [];

    final datasource = ref.watch(productoDatasourceProvider);
    return await datasource.searchProductos(
      clienteId: params.clienteId,
      search: params.searchTerm,
      pageSize: params.pageSize,
    );
  },
);

/// Provider para buscar consumidores por nombre
/// Recibe clienteId y searchTerm como parámetros
final consumidoresSearchProvider =
    FutureProvider.family<List<Consumidor>, ConsumidoresSearchParams>(
  (ref, params) async {
    if (params.searchTerm.length < 3) return [];

    final datasource = ref.watch(consumidorDatasourceProvider);
    return await datasource.searchConsumidores(
      clienteId: params.clienteId,
      search: params.searchTerm,
      pageSize: params.pageSize,
    );
  },
);
