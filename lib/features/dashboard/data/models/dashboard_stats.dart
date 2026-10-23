import 'package:json_annotation/json_annotation.dart';

part 'dashboard_stats.g.dart';

@JsonSerializable()
class DashboardStats {
  final double ventasDia;
  final int cantidadFacturas;
  final double totalIngresos;
  final double totalGastos;
  final int cantidadAlertas;

  DashboardStats({
    required this.ventasDia,
    required this.cantidadFacturas,
    required this.totalIngresos,
    required this.totalGastos,
    required this.cantidadAlertas,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardStatsToJson(this);

  static DashboardStats empty() {
    return DashboardStats(
      ventasDia: 0,
      cantidadFacturas: 0,
      totalIngresos: 0,
      totalGastos: 0,
      cantidadAlertas: 0,
    );
  }
}
