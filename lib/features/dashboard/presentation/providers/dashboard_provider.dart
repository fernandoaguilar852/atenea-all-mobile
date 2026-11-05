import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../../core/providers/cache_provider.dart';
import '../../../../core/services/cache_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/models/dashboard_stats.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/dashboard_repository.dart';

// ============================================================================
// PROVIDERS DE REPOSITORIO Y DATASOURCE
// ============================================================================

/// Provider del datasource remoto
final dashboardRemoteDatasourceProvider =
    Provider<DashboardRemoteDatasource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DashboardRemoteDatasource(dioClient.dio);
});

/// Provider del repositorio de dashboard
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final remoteDatasource = ref.watch(dashboardRemoteDatasourceProvider);
  return DashboardRepositoryImpl(remoteDatasource);
});

// ============================================================================
// STATE CLASS
// ============================================================================

class DashboardState {
  final DashboardStats? stats;
  final bool isLoading;
  final String? error;

  DashboardState({
    this.stats,
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    DashboardStats? stats,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ============================================================================
// NOTIFIER
// ============================================================================

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;
  final Ref _ref;

  DashboardNotifier(this._repository, this._ref) : super(DashboardState());

  /// Carga estadísticas con patrón stale-while-revalidate (como Instagram)
  /// 1. Muestra cache inmediatamente (si existe)
  /// 2. Actualiza en background
  /// 3. Muestra datos frescos cuando llegan
  Future<void> loadStats({bool forceRefresh = false}) async {
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final cacheService = _ref.read(cacheServiceProvider);
      final cacheKey = CacheKeys.dashboardStats(user.clienteId);

      // Paso 1: Cargar cache inmediatamente (RÁPIDO ⚡)
      if (!forceRefresh) {
        final cachedData = await cacheService.getStale<Map<String, dynamic>>(cacheKey);
        if (cachedData != null) {
          try {
            final stats = DashboardStats.fromJson(cachedData);
            // Mostrar datos cached SIN bloquear la UI
            state = state.copyWith(stats: stats, isLoading: true, error: null);
          } catch (e) {
            debugPrint('Error parsing cached dashboard: $e');
          }
        } else {
          // No hay cache, mostrar loading completo
          state = state.copyWith(isLoading: true, error: null);
        }
      } else {
        state = state.copyWith(isLoading: true, error: null);
      }

      // Paso 2: Fetch datos frescos en background
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
      final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final dateFormat = DateFormat('yyyy-MM-dd');
      final startDateStr = dateFormat.format(startDate);
      final endDateStr = dateFormat.format(endDate);

      final stats = await _repository.getStats(
        clienteId: user.clienteId,
        startDate: startDateStr,
        endDate: endDateStr,
      );

      // Paso 3: Guardar en cache y actualizar UI
      await cacheService.set(
        key: cacheKey,
        data: stats.toJson(),
        duration: const Duration(minutes: 5), // Cache por 5 minutos
      );

      state = state.copyWith(stats: stats, isLoading: false);
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');

      // Si hay datos cached, mantenerlos y solo mostrar error
      if (state.stats != null) {
        state = state.copyWith(isLoading: false, error: 'Error al actualizar');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Error al cargar estadísticas',
          stats: DashboardStats.empty(),
        );
      }
    }
  }

  Future<void> refresh() async {
    await loadStats(forceRefresh: true);
  }
}

// ============================================================================
// PROVIDER
// ============================================================================

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return DashboardNotifier(repository, ref);
});
