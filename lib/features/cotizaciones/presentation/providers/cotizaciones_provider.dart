import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../../core/providers/cache_provider.dart';
import '../../../../core/services/cache_service.dart';
import '../../data/datasources/cotizaciones_remote_datasource.dart';
import '../../data/repositories/cotizaciones_repository_impl.dart';
import '../../domain/entities/cotizacion_entity.dart';
import '../../domain/entities/nueva_cotizacion_entity.dart';
import '../../domain/repositories/cotizaciones_repository.dart';

// ============================================================================
// PROVIDERS DE INFRAESTRUCTURA
// ============================================================================

/// Provider del datasource remoto
final cotizacionesRemoteDatasourceProvider =
    Provider<CotizacionesRemoteDatasource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CotizacionesRemoteDatasource(dioClient.dio);
});

/// Provider del repositorio
final cotizacionesRepositoryProvider = Provider<CotizacionesRepository>((ref) {
  final datasource = ref.watch(cotizacionesRemoteDatasourceProvider);
  return CotizacionesRepositoryImpl(datasource);
});

// ============================================================================
// STATE PROVIDER
// ============================================================================

/// Resultado de crear una cotización (cabecera + líneas una por una)
class CrearCotizacionResultado {
  /// Cotización creada. Es null si falló la creación de la cabecera.
  final CotizacionCreadaEntity? cotizacion;

  /// Líneas creadas correctamente en esta operación
  final int lineasCreadas;

  /// Líneas que faltan por crear (vacío si todo salió bien)
  final List<NuevaLineaCotizacion> lineasPendientes;

  /// Mensaje del primer error ocurrido (null si todo salió bien)
  final String? error;

  const CrearCotizacionResultado({
    required this.cotizacion,
    required this.lineasCreadas,
    required this.lineasPendientes,
    this.error,
  });

  /// Cabecera creada y todas las líneas guardadas
  bool get completo => cotizacion != null && lineasPendientes.isEmpty;
}

/// Estado de la lista de cotizaciones
class CotizacionesState {
  final CotizacionesListEntity? data;
  final bool isLoading;
  final bool isLoadingMore; // Loading para paginación (no bloquea UI)
  final String? error;

  const CotizacionesState({
    this.data,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  CotizacionesState copyWith({
    CotizacionesListEntity? data,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
  }) {
    return CotizacionesState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

/// Notifier para gestionar el estado de cotizaciones
class CotizacionesNotifier extends StateNotifier<CotizacionesState> {
  final CotizacionesRepository _repository;
  final Ref _ref;

  CotizacionesNotifier(this._repository, this._ref)
      : super(const CotizacionesState());

  /// Genera una clave de cache única basada en los filtros
  String _getCacheKey({
    required int clienteId,
    required int pageNumber,
    required int pageSize,
    String? search,
    required String origen,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return CacheKeys.cotizaciones(
      clienteId: clienteId,
      pageNumber: pageNumber,
      pageSize: pageSize,
      search: (search ?? '').trim().toLowerCase(),
      origen: origen,
      startDate: startDate?.toIso8601String().split('T')[0] ?? 'all',
      endDate: endDate?.toIso8601String().split('T')[0] ?? 'all',
    );
  }

  /// Carga la lista de cotizaciones con cache (stale-while-revalidate)
  Future<void> loadCotizaciones({
    required int clienteId,
    int pageNumber = 1,
    int pageSize = 10,
    String? search,
    String origen = CotizacionOrigen.defaultOrigen,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    try {
      final cacheService = _ref.read(cacheServiceProvider);
      final cacheKey = _getCacheKey(
        clienteId: clienteId,
        pageNumber: pageNumber,
        pageSize: pageSize,
        search: search,
        origen: origen,
        startDate: startDate,
        endDate: endDate,
      );

      // Determinar tipo de loading: si hay datos, usar isLoadingMore (no bloquea UI)
      final hasExistingData = state.data != null;

      // Paso 1: Mostrar estado de loading apropiado
      if (!forceRefresh) {
        final cachedData = await cacheService.getStale<Map<String, dynamic>>(cacheKey);
        if (cachedData != null) {
          // Hay cache, mantener datos actuales y cargar en background
          state = state.copyWith(
            isLoadingMore: hasExistingData,
            isLoading: !hasExistingData,
            error: null,
          );
          debugPrint('Cache hit for cotizaciones (showing fresh data will load...)');
        } else {
          // No hay cache
          state = state.copyWith(
            isLoadingMore: hasExistingData,
            isLoading: !hasExistingData,
            error: null,
          );
        }
      } else {
        state = state.copyWith(
          isLoadingMore: hasExistingData,
          isLoading: !hasExistingData,
          error: null,
        );
      }

      // Paso 2: Fetch datos frescos
      final result = await _repository.getCotizaciones(
        clienteId: clienteId,
        pageNumber: pageNumber,
        pageSize: pageSize,
        search: search,
        origen: origen,
        startDate: startDate,
        endDate: endDate,
      );

      // Paso 3: Guardar en cache y actualizar UI
      await cacheService.set(
        key: cacheKey,
        data: {
          'pagination': {
            'currentPage': result.pagination?.currentPage,
            'totalPages': result.pagination?.totalPages,
            'totalItems': result.pagination?.totalItems,
            'hasNext': result.pagination?.hasNext,
            'hasPrevious': result.pagination?.hasPrevious,
          },
        },
        duration: const Duration(minutes: 5), // Cache por 5 minutos
      );

      state = state.copyWith(
        data: result,
        isLoading: false,
        isLoadingMore: false,
      );
    } catch (e) {
      debugPrint('Error loading cotizaciones: $e');

      // Si hay datos existentes, mantenerlos visibles y solo mostrar error suave
      if (state.data != null) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: 'Error al actualizar',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: 'Error al cargar cotizaciones: ${e.toString()}',
        );
      }
    }
  }

  /// Limpia todo el cache de cotizaciones de un cliente
  Future<void> clearCache(int clienteId) async {
    try {
      final cacheService = _ref.read(cacheServiceProvider);
      await cacheService.clearByPattern(CacheKeys.cotizacionesPrefix(clienteId));
      debugPrint('Cache de cotizaciones limpiado para cliente $clienteId');
    } catch (e) {
      debugPrint('Error clearing cotizaciones cache: $e');
    }
  }

  /// Crea una cotización: primero la cabecera y luego, con el id generado,
  /// cada línea una por una (en orden). Si una línea falla, se detiene y
  /// devuelve las que quedaron pendientes para poder reintentarlas.
  Future<CrearCotizacionResultado> crearCotizacion({
    required int clienteId,
    required NuevaCotizacion cotizacion,
  }) async {
    // 1. Cabecera
    final CotizacionCreadaEntity creada;
    try {
      creada = await _repository.crearCotizacion(
        clienteId: clienteId,
        cotizacion: cotizacion,
      );
    } catch (e) {
      debugPrint('Error creando cabecera de cotización: $e');
      return CrearCotizacionResultado(
        cotizacion: null,
        lineasCreadas: 0,
        lineasPendientes: cotizacion.lineas,
        error: _mensajeError(e),
      );
    }

    // 2. Líneas, una por una
    final resultado = await _crearLineas(
      clienteId: clienteId,
      cotizacion: creada,
      lineas: cotizacion.lineas,
    );

    // La cabecera ya existe: limpiar el cache para que el listado la muestre
    await clearCache(clienteId);

    return resultado;
  }

  /// Continúa con las líneas pendientes de una cotización ya creada
  /// (no vuelve a crear la cabecera).
  Future<CrearCotizacionResultado> reintentarDetalles({
    required int clienteId,
    required CotizacionCreadaEntity cotizacion,
    required List<NuevaLineaCotizacion> pendientes,
  }) async {
    final resultado = await _crearLineas(
      clienteId: clienteId,
      cotizacion: cotizacion,
      lineas: pendientes,
    );

    await clearCache(clienteId);

    return resultado;
  }

  /// Crea las líneas en orden; se detiene en el primer error
  Future<CrearCotizacionResultado> _crearLineas({
    required int clienteId,
    required CotizacionCreadaEntity cotizacion,
    required List<NuevaLineaCotizacion> lineas,
  }) async {
    var creadas = 0;

    for (final linea in lineas) {
      try {
        await _repository.crearDetalle(
          clienteId: clienteId,
          cotizacionId: cotizacion.cotizacionId,
          linea: linea,
        );
        creadas++;
      } catch (e) {
        debugPrint('Error creando detalle de cotización: $e');
        return CrearCotizacionResultado(
          cotizacion: cotizacion,
          lineasCreadas: creadas,
          lineasPendientes: lineas.sublist(creadas),
          error: _mensajeError(e),
        );
      }
    }

    return CrearCotizacionResultado(
      cotizacion: cotizacion,
      lineasCreadas: creadas,
      lineasPendientes: const [],
    );
  }

  /// Extrae un mensaje legible del error (usa el del API si viene)
  String _mensajeError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['messageResponse'] is Map) {
        final msg = data['messageResponse'] as Map;
        final detalle = msg['responseDetails'] ?? msg['responseMessage'];
        if (detalle != null && detalle.toString().isNotEmpty) {
          return detalle.toString();
        }
      }
      if (e.response == null) return 'Sin conexión con el servidor';
      return e.message ?? 'Error ${e.response?.statusCode}';
    }
    return e.toString();
  }
}

/// Provider del estado de cotizaciones
final cotizacionesProvider =
    StateNotifierProvider<CotizacionesNotifier, CotizacionesState>((ref) {
  final repository = ref.watch(cotizacionesRepositoryProvider);
  return CotizacionesNotifier(repository, ref);
});
