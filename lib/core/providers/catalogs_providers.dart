import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/caja_datasource.dart';
import '../datasources/tipo_producto_datasource.dart';
import '../models/caja.dart';
import '../models/tipo_producto.dart';
import 'dio_provider.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

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

// ============================================================================
// STATE PROVIDERS
// ============================================================================

/// Provider para obtener lista de tipos de producto
final tiposProductoProvider = FutureProvider<List<TipoProducto>>((ref) async {
  final datasource = ref.watch(tipoProductoDatasourceProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) return [];

  return await datasource.getTiposProducto(
    clienteId: user.clienteId,
    pageSize: 100,
  );
});

/// Provider para obtener lista de cajas
final cajasProvider = FutureProvider.family<List<Caja>, String?>((ref, estado) async {
  final datasource = ref.watch(cajaDatasourceProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) return [];

  return await datasource.getCajas(
    clienteId: user.clienteId,
    estado: estado,
    pageSize: 100,
  );
});
