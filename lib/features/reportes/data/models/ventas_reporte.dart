import 'package:json_annotation/json_annotation.dart';
import 'reporte_encabezado.dart';

part 'ventas_reporte.g.dart';

@JsonSerializable()
class VentasReporte {
  final ReporteEncabezado encabezado;
  final List<VentaRow> reporteVentas;
  final VentasResumen resumen;
  final ReportePagination? pagination;

  VentasReporte({
    required this.encabezado,
    required this.reporteVentas,
    required this.resumen,
    this.pagination,
  });

  factory VentasReporte.fromJson(Map<String, dynamic> json) =>
      _$VentasReporteFromJson(json);

  Map<String, dynamic> toJson() => _$VentasReporteToJson(this);
}

@JsonSerializable()
class VentaRow {
  final int productoId;
  final String codigoBarras;
  final String nombreProducto;
  final int categoriaId;
  final String nombreCategoria;
  final double precioVentaUnitario;
  final int cantidadVendida;
  final double totalVentas;

  VentaRow({
    required this.productoId,
    required this.codigoBarras,
    required this.nombreProducto,
    required this.categoriaId,
    required this.nombreCategoria,
    required this.precioVentaUnitario,
    required this.cantidadVendida,
    required this.totalVentas,
  });

  factory VentaRow.fromJson(Map<String, dynamic> json) =>
      _$VentaRowFromJson(json);

  Map<String, dynamic> toJson() => _$VentaRowToJson(this);
}

@JsonSerializable()
class VentasResumen {
  final int totalProductosVendidos;
  final int totalCantidadVendida;
  final double totalVentas;

  VentasResumen({
    required this.totalProductosVendidos,
    required this.totalCantidadVendida,
    required this.totalVentas,
  });

  factory VentasResumen.fromJson(Map<String, dynamic> json) =>
      _$VentasResumenFromJson(json);

  Map<String, dynamic> toJson() => _$VentasResumenToJson(this);
}
