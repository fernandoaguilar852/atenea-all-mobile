import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cache_service.dart';

/// Provider del servicio de cache
final cacheServiceProvider = Provider<CacheService>((ref) {
  final service = CacheService();

  // Inicializar automáticamente
  service.init();

  // Limpiar cache expirado al iniciar
  Future.delayed(Duration.zero, () => service.clearExpired());

  // Dispose al destruir
  ref.onDispose(() => service.dispose());

  return service;
});
