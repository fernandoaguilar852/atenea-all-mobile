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
  @JsonKey(name: 'codigoBarras', defaultValue: '')
  final String codigoBarras;
  @JsonKey(name: 'productoNombre')
  final String nombreProducto;
  @JsonKey(name: 'categoriaId', defaultValue: 0)
  final int categoriaId;
  @JsonKey(name: 'categoriaNombre')
  final String nombreCategoria;
  @JsonKey(name: 'precioPromedio')
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
  @JsonKey(name: 'totalTransacciones', defaultValue: 0)
  final int totalCantidadVendida;
  @JsonKey(name: 'totalGeneral')
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
