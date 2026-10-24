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
  @JsonKey(name: 'productoNombre', defaultValue: '')
  final String nombreProducto;
  @JsonKey(name: 'categoriaNombre', defaultValue: '')
  final String nombreCategoria;
  @JsonKey(defaultValue: 0)
  final int cantidadVendida;
  @JsonKey(name: 'precioPromedio', defaultValue: 0.0)
  final double precioVentaUnitario;
  @JsonKey(name: 'subtotalVentas', defaultValue: 0.0)
  final double subtotal;
  @JsonKey(defaultValue: 0.0)
  final double? descuentosAplicados;
  @JsonKey(defaultValue: 0.0)
  final double? impuestosAplicados;
  @JsonKey(defaultValue: 0.0)
  final double totalVentas;
  @JsonKey(defaultValue: 0)
  final int? numeroTransacciones;

  VentaRow({
    required this.productoId,
    required this.nombreProducto,
    required this.nombreCategoria,
    required this.cantidadVendida,
    required this.precioVentaUnitario,
    required this.subtotal,
    this.descuentosAplicados,
    this.impuestosAplicados,
    required this.totalVentas,
    this.numeroTransacciones,
  });

  factory VentaRow.fromJson(Map<String, dynamic> json) =>
      _$VentaRowFromJson(json);

  Map<String, dynamic> toJson() => _$VentaRowToJson(this);
}

@JsonSerializable()
class VentasResumen {
  @JsonKey(defaultValue: 0)
  final int totalProductosVendidos;
  @JsonKey(defaultValue: 0)
  final int totalTransacciones;
  @JsonKey(defaultValue: 0.0)
  final double subtotalGeneral;
  @JsonKey(defaultValue: 0.0)
  final double descuentosGeneral;
  @JsonKey(defaultValue: 0.0)
  final double impuestosGeneral;
  @JsonKey(defaultValue: 0.0)
  final double totalGeneral;

  VentasResumen({
    required this.totalProductosVendidos,
    required this.totalTransacciones,
    required this.subtotalGeneral,
    required this.descuentosGeneral,
    required this.impuestosGeneral,
    required this.totalGeneral,
  });

  factory VentasResumen.fromJson(Map<String, dynamic> json) =>
      _$VentasResumenFromJson(json);

  Map<String, dynamic> toJson() => _$VentasResumenToJson(this);
}
