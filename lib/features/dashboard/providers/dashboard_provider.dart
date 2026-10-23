import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/providers/dio_provider.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../data/models/dashboard_stats.dart';

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

class DashboardNotifier extends StateNotifier<DashboardState> {
  final Dio _dio;
  final Ref _ref;

  DashboardNotifier(this._dio, this._ref) : super(DashboardState());

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

      // Llamar al API
      final response = await _dio.get(
        ApiConstants.buildUrl(ApiConstants.consultaEstadisticas),
        queryParameters: {
          'clienteId': user.clienteId,
          'startDate': startDateStr,
          'endDate': endDateStr,
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final stats = DashboardStats.fromJson(response.data['data']);
        state = state.copyWith(stats: stats, isLoading: false);
      } else {
        throw Exception('Error al obtener estadísticas');
      }
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

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DashboardNotifier(dioClient.dio, ref);
});
