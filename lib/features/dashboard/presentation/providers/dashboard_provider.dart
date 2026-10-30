import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/dio_provider.dart';
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

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Obtener clienteId del usuario actual
      final user = _ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener fecha actual con horas específicas
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
      final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Formatear fechas para el query param (yyyy-MM-dd)
      final dateFormat = DateFormat('yyyy-MM-dd');
      final startDateStr = dateFormat.format(startDate);
      final endDateStr = dateFormat.format(endDate);

      // Llamar al repositorio
      final stats = await _repository.getStats(
        clienteId: user.clienteId,
        startDate: startDateStr,
        endDate: endDateStr,
      );

      state = state.copyWith(stats: stats, isLoading: false);
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar estadísticas',
        stats: DashboardStats.empty(),
      );
    }
  }

  Future<void> refresh() async {
    await loadStats();
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
