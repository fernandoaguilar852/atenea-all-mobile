import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

/// Servicio de cache local para mejorar performance
/// Implementa patrón "stale-while-revalidate" como Instagram/Nequi
class CacheService {
  static const String _cacheBoxName = 'app_cache';
  static const Duration _defaultCacheDuration = Duration(hours: 1);

  late Box _cacheBox;
  bool _initialized = false;

  /// Inicializa el servicio de cache
  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();
    _cacheBox = await Hive.openBox(_cacheBoxName);
    _initialized = true;
  }

  /// Guarda datos en cache con timestamp
  Future<void> set({
    required String key,
    required dynamic data,
    Duration? duration,
  }) async {
    await _ensureInitialized();

    final cacheEntry = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'duration': (duration ?? _defaultCacheDuration).inMilliseconds,
    };

    await _cacheBox.put(key, json.encode(cacheEntry));
  }

  /// Obtiene datos del cache si no han expirado
  Future<T?> get<T>(String key) async {
    await _ensureInitialized();

    final cachedJson = _cacheBox.get(key);
    if (cachedJson == null) return null;

    try {
      final cacheEntry = json.decode(cachedJson as String);
      final timestamp = cacheEntry['timestamp'] as int;
      final duration = cacheEntry['duration'] as int;
      final data = cacheEntry['data'];

      // Verificar si el cache expiró
      final now = DateTime.now().millisecondsSinceEpoch;
      final expiresAt = timestamp + duration;

      if (now > expiresAt) {
        // Cache expirado, eliminar
        await _cacheBox.delete(key);
        return null;
      }

      return data as T?;
    } catch (e) {
      // Si hay error parseando, eliminar cache corrupto
      await _cacheBox.delete(key);
      return null;
    }
  }

  /// Obtiene datos del cache SIN verificar expiración
  /// Útil para patrón stale-while-revalidate
  Future<T?> getStale<T>(String key) async {
    await _ensureInitialized();

    final cachedJson = _cacheBox.get(key);
    if (cachedJson == null) return null;

    try {
      final cacheEntry = json.decode(cachedJson as String);
      return cacheEntry['data'] as T?;
    } catch (e) {
      await _cacheBox.delete(key);
      return null;
    }
  }

  /// Verifica si existe cache para una key (sin importar si expiró)
  Future<bool> has(String key) async {
    await _ensureInitialized();
    return _cacheBox.containsKey(key);
  }

  /// Elimina un item del cache
  Future<void> delete(String key) async {
    await _ensureInitialized();
    await _cacheBox.delete(key);
  }

  /// Limpia todo el cache
  Future<void> clear() async {
    await _ensureInitialized();
    await _cacheBox.clear();
  }

  /// Limpia cache por patrón (prefix)
  Future<void> clearByPattern(String pattern) async {
    await _ensureInitialized();
    final keysToDelete = <String>[];

    for (var key in _cacheBox.keys) {
      if ((key as String).startsWith(pattern)) {
        keysToDelete.add(key);
      }
    }

    for (var key in keysToDelete) {
      await _cacheBox.delete(key);
    }
  }

  /// Limpia cache expirado
  Future<void> clearExpired() async {
    await _ensureInitialized();

    final now = DateTime.now().millisecondsSinceEpoch;
    final keysToDelete = <String>[];

    for (var key in _cacheBox.keys) {
      try {
        final cachedJson = _cacheBox.get(key);
        if (cachedJson == null) continue;

        final cacheEntry = json.decode(cachedJson as String);
        final timestamp = cacheEntry['timestamp'] as int;
        final duration = cacheEntry['duration'] as int;
        final expiresAt = timestamp + duration;

        if (now > expiresAt) {
          keysToDelete.add(key as String);
        }
      } catch (e) {
        // Si hay error, marcar para eliminar
        keysToDelete.add(key as String);
      }
    }

    for (var key in keysToDelete) {
      await _cacheBox.delete(key);
    }
  }

  /// Asegura que el servicio esté inicializado
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }

  /// Cierra el servicio
  Future<void> dispose() async {
    if (_initialized) {
      await _cacheBox.close();
      _initialized = false;
    }
  }
}

/// Keys de cache para diferentes features
class CacheKeys {
  static const String prefix = 'atenea_local_';

  // Dashboard
  static String dashboardStats(int clienteId) => '${prefix}dashboard_$clienteId';

  // Ventas
  static String ventas({
    required int clienteId,
    required int pageNumber,
    required int pageSize,
    required String estado,
    required int cajaId,
    required int consumidorId,
    required String startDate,
    required String endDate,
  }) =>
      '${prefix}ventas_${clienteId}_p${pageNumber}_ps${pageSize}_e${estado}_c${cajaId}_con${consumidorId}_${startDate}_$endDate';

  static String ventasPrefix(int clienteId) => '${prefix}ventas_$clienteId';
  static String ventaDetalle(int ventaId) => '${prefix}venta_detail_$ventaId';

  // Movimientos
  static String movimientos({
    required int clienteId,
    required int pageNumber,
    required int pageSize,
    required String tipo,
    required int productoId,
    required int proveedorId,
    required String startDate,
    required String endDate,
  }) =>
      '${prefix}movimientos_${clienteId}_p${pageNumber}_ps${pageSize}_t${tipo}_prod${productoId}_prov${proveedorId}_${startDate}_$endDate';

  static String movimientosPrefix(int clienteId) => '${prefix}movimientos_$clienteId';

  // Resoluciones
  static String resoluciones({
    required int clienteId,
    required int pageNumber,
    required int pageSize,
    required String activo,
  }) =>
      '${prefix}resoluciones_${clienteId}_p${pageNumber}_ps${pageSize}_a$activo';

  static String resolucionesPrefix(int clienteId) => '${prefix}resoluciones_$clienteId';

  // Reportes
  static String reportes(int clienteId, String type) => '${prefix}reportes_${clienteId}_$type';

  // Notificaciones
  static String notificaciones(int clienteId) => '${prefix}notificaciones_$clienteId';

  // Productos (para autocomplete)
  static String productos(int clienteId) => '${prefix}productos_$clienteId';

  // Consumidores (para autocomplete)
  static String consumidores(int clienteId) => '${prefix}consumidores_$clienteId';

  // Reportes - Ventas
  static String reporteVentas({
    required String startDate,
    required String endDate,
    required int pageNumber,
    required int pageSize,
    required int productoId,
    required int categoriaId,
    required int cajaId,
    required bool incluirAnuladas,
  }) =>
      '${prefix}reporte_ventas_${startDate}_${endDate}_p${pageNumber}_ps${pageSize}_prod${productoId}_cat${categoriaId}_caja${cajaId}_anuladas$incluirAnuladas';

  static String reporteVentasPrefix = '${prefix}reporte_ventas';
}
