import 'package:json_annotation/json_annotation.dart';
import 'reporte_encabezado.dart';

part 'costo_beneficio_reporte.g.dart';

@JsonSerializable()
class CostoBeneficioReporte {
  final ReporteEncabezado encabezado;
  final List<CostoBeneficioRow> productos;
  final CostoBeneficioResumen resumen;
  final CostoBeneficioMetadatos metadatos;
  final ReportePagination? pagination;

  CostoBeneficioReporte({
    required this.encabezado,
    required this.productos,
    required this.resumen,
    required this.metadatos,
    this.pagination,
  });

  factory CostoBeneficioReporte.fromJson(Map<String, dynamic> json) =>
      _$CostoBeneficioReporteFromJson(json);

  Map<String, dynamic> toJson() => _$CostoBeneficioReporteToJson(this);
}

@JsonSerializable()
class CostoBeneficioRow {
  final int productoId;
  final String? codigoBarras;
  final String nombreProducto;
  final int categoriaId;
  final String nombreCategoria;
  final int cantidadVendida;
  final double precioVenta;
  final double costoUnitario;
  final double ingresoTotal;
  final double costoTotal;
  final double beneficioNeto;
  final double margenPorcentaje;

  CostoBeneficioRow({
    required this.productoId,
    this.codigoBarras,
    required this.nombreProducto,
    required this.categoriaId,
    required this.nombreCategoria,
    required this.cantidadVendida,
    required this.precioVenta,
    required this.costoUnitario,
    required this.ingresoTotal,
    required this.costoTotal,
    required this.beneficioNeto,
    required this.margenPorcentaje,
  });

  factory CostoBeneficioRow.fromJson(Map<String, dynamic> json) =>
      _$CostoBeneficioRowFromJson(json);

  Map<String, dynamic> toJson() => _$CostoBeneficioRowToJson(this);
}

@JsonSerializable()
class CostoBeneficioResumen {
  final int totalProductos;
  final int totalCantidadVendida;
  final double totalIngresos;
  final double totalCostos;
  final double beneficioNetoTotal;
  final double margenPromedioGeneral;

  CostoBeneficioResumen({
    required this.totalProductos,
    required this.totalCantidadVendida,
    required this.totalIngresos,
    required this.totalCostos,
    required this.beneficioNetoTotal,
    required this.margenPromedioGeneral,
  });

  factory CostoBeneficioResumen.fromJson(Map<String, dynamic> json) =>
      _$CostoBeneficioResumenFromJson(json);

  Map<String, dynamic> toJson() => _$CostoBeneficioResumenToJson(this);
}

@JsonSerializable()
class CostoBeneficioMetadatos {
  final String fechaInicio;
  final String fechaFin;
  final int diasAnalisis;
  final String? productoMasRentable;
  final double? mayorMargen;
  final String? productoMenosRentable;
  final double? menorMargen;

  CostoBeneficioMetadatos({
    required this.fechaInicio,
    required this.fechaFin,
    required this.diasAnalisis,
    this.productoMasRentable,
    this.mayorMargen,
    this.productoMenosRentable,
    this.menorMargen,
  });

  factory CostoBeneficioMetadatos.fromJson(Map<String, dynamic> json) =>
      _$CostoBeneficioMetadatosFromJson(json);

  Map<String, dynamic> toJson() => _$CostoBeneficioMetadatosToJson(this);
}
