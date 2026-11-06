import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/datasources/producto_datasource.dart';
import '../../../../core/datasources/producto_write_datasource.dart';
import '../../../../core/models/producto.dart';
import '../../../../core/providers/dio_provider.dart';

// ============================================================================
// PROVIDERS DE INFRAESTRUCTURA
// ============================================================================

/// Provider del datasource de productos (Read)
final productoDatasourceProvider = Provider<ProductoDatasource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ProductoDatasource(dioClient.dio);
});

/// Provider del datasource de productos (Write - Create, Update, Delete)
final productoWriteDatasourceProvider = Provider<ProductoWriteDatasource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ProductoWriteDatasource(dioClient.dio);
});

// ============================================================================
// STATE PROVIDER
// ============================================================================

/// Estado de la lista de productos
class ProductosState {
  final List<Producto> productos;
  final int totalElements;
  final bool hasMoreElements;
  final bool isLoading;
  final String? error;

  const ProductosState({
    this.productos = const [],
    this.totalElements = 0,
    this.hasMoreElements = false,
    this.isLoading = false,
    this.error,
  });

  ProductosState copyWith({
    List<Producto>? productos,
    int? totalElements,
    bool? hasMoreElements,
    bool? isLoading,
    String? error,
  }) {
    return ProductosState(
      productos: productos ?? this.productos,
      totalElements: totalElements ?? this.totalElements,
      hasMoreElements: hasMoreElements ?? this.hasMoreElements,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Entry del cache en RAM con timestamp
class _CacheEntry {
  final ProductosState state;
  final DateTime timestamp;

  _CacheEntry(this.state, this.timestamp);

  bool isExpired(Duration ttl) {
    return DateTime.now().difference(timestamp) > ttl;
  }
}

/// Notifier para gestionar el estado de productos
class ProductosNotifier extends StateNotifier<ProductosState> {
  final ProductoDatasource _datasource;
  final ProductoWriteDatasource _writeDatasource;

  // 🚀 Cache en memoria (RAM) con TTL - navegación instantánea + auto-refresh cada 2 min
  final Map<String, _CacheEntry> _memoryCache = {};
  static const Duration _cacheTTL = Duration(minutes: 2);

  ProductosNotifier(this._datasource, this._writeDatasource) : super(const ProductosState());

  /// Genera una clave de cache única basada en los filtros
  String _getCacheKey({
    required int clienteId,
    required int pageNumber,
    required int pageSize,
    String? search,
  }) {
    return 'productos_${clienteId}_page${pageNumber}_size${pageSize}_search${search ?? 'all'}';
  }

  /// Carga la lista de productos con paginación y cache con TTL
  Future<void> loadProductos({
    required int clienteId,
    required int pageNumber,
    required int pageSize,
    String? search,
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = _getCacheKey(
        clienteId: clienteId,
        pageNumber: pageNumber,
        pageSize: pageSize,
        search: search,
      );

      // ⚡ PASO 1: Verificar cache en RAM con TTL
      if (!forceRefresh && _memoryCache.containsKey(cacheKey)) {
        final cacheEntry = _memoryCache[cacheKey]!;

        if (!cacheEntry.isExpired(_cacheTTL)) {
          // Cache válido (< 2 min) - INSTANTÁNEO ⚡
          debugPrint('✨ Productos RAM cache HIT (${DateTime.now().difference(cacheEntry.timestamp).inSeconds}s) - Carga instantánea!');
          state = cacheEntry.state;
          return; // NO hacer petición al servidor
        } else {
          // Cache expirado (> 2 min) - necesita actualizar
          debugPrint('⏰ Productos RAM cache EXPIRADO - Consultando servidor para datos frescos...');
        }
      } else {
        debugPrint('🌐 Productos RAM cache MISS - Consultando servidor...');
      }

      // PASO 2: Cache expirado o no existe - consultar servidor
      state = state.copyWith(isLoading: true, error: null);

      // PASO 3: Fetch datos frescos del servidor
      final response = await _datasource.getProductos(
        clienteId: clienteId,
        pageNumber: pageNumber,
        pageSize: pageSize,
        search: search,
      );

      // PASO 4: Crear nuevo state y guardar en RAM con timestamp
      final newState = state.copyWith(
        productos: response.data.products,
        totalElements: response.pagination?.totalElement ?? 0,
        hasMoreElements: response.pagination?.hasMoreElements ?? false,
        isLoading: false,
      );

      _memoryCache[cacheKey] = _CacheEntry(newState, DateTime.now());
      debugPrint('💾 Productos guardado en RAM (Total páginas: ${_memoryCache.length}, TTL: ${_cacheTTL.inMinutes} min)');

      state = newState;
    } catch (e) {
      debugPrint('Error loading productos: $e');

      // Si hay datos cached, mantenerlos y solo mostrar error
      if (state.productos.isNotEmpty) {
        state = state.copyWith(isLoading: false, error: 'Error al actualizar');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Error al cargar productos: ${e.toString()}',
        );
      }
    }
  }

  /// Limpia todo el cache de productos
  void clearCache() {
    _memoryCache.clear();
    debugPrint('🗑️ Productos RAM cache limpiado');
  }

  /// Limpia el error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Crea un nuevo producto
  Future<Producto> createProducto({
    required int clienteId,
    required int tipoProductoId,
    required String nombre,
    String? codExterno,
    String? codBarras,
    required double precio,
    required String unidadMedida,
    required double stockTotal,
    required double stockMinimo,
    required bool manejaStock,
    required int ivaId,
  }) async {
    final producto = await _writeDatasource.createProducto(
      clienteId: clienteId,
      tipoProductoId: tipoProductoId,
      nombre: nombre,
      codExterno: codExterno,
      codBarras: codBarras,
      precio: precio,
      unidadMedida: unidadMedida,
      stockTotal: stockTotal,
      stockMinimo: stockMinimo,
      manejaStock: manejaStock,
      ivaId: ivaId,
    );

    // Limpiar cache para forzar refresh en próxima consulta
    clearCache();

    return producto;
  }
}

/// Provider principal de productos
final productosProvider = StateNotifierProvider<ProductosNotifier, ProductosState>((ref) {
  final datasource = ref.watch(productoDatasourceProvider);
  final writeDatasource = ref.watch(productoWriteDatasourceProvider);
  return ProductosNotifier(datasource, writeDatasource);
});
