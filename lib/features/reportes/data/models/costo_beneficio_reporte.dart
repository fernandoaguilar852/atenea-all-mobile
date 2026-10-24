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
  @JsonKey(defaultValue: '')
  final String? codigoBarras;
  @JsonKey(name: 'productoNombre', defaultValue: '')
  final String nombreProducto;
  @JsonKey(defaultValue: 0)
  final int? categoriaId;
  @JsonKey(name: 'categoriaNombre', defaultValue: '')
  final String nombreCategoria;
  @JsonKey(defaultValue: 0)
  final int cantidadVendida;
  @JsonKey(defaultValue: 0.0)
  final double? precioVenta;
  @JsonKey(name: 'costoUnitarioPromedio', defaultValue: 0.0)
  final double costoUnitario;
  @JsonKey(name: 'ingresosTotal', defaultValue: 0.0)
  final double ingresoTotal;
  @JsonKey(defaultValue: 0.0)
  final double costoTotal;
  @JsonKey(name: 'margenPesos', defaultValue: 0.0)
  final double beneficioNeto;
  @JsonKey(defaultValue: 0.0)
  final double margenPorcentaje;

  CostoBeneficioRow({
    required this.productoId,
    this.codigoBarras = '',
    required this.nombreProducto,
    this.categoriaId,
    required this.nombreCategoria,
    required this.cantidadVendida,
    this.precioVenta,
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
  @JsonKey(name: 'totalProductosAnalizados', defaultValue: 0)
  final int totalProductos;
  @JsonKey(name: 'cantidadTotalVendida', defaultValue: 0)
  final int totalCantidadVendida;
  @JsonKey(name: 'ingresosTotalGeneral', defaultValue: 0.0)
  final double totalIngresos;
  @JsonKey(name: 'costoTotalGeneral', defaultValue: 0.0)
  final double totalCostos;
  @JsonKey(name: 'margenTotalPesos', defaultValue: 0.0)
  final double beneficioNetoTotal;
  @JsonKey(name: 'margenTotalPorcentaje', defaultValue: 0.0)
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
  @JsonKey(defaultValue: 0)
  final int ventanaBusquedaMeses;
  @JsonKey(defaultValue: [])
  final List<String> advertencias;

  CostoBeneficioMetadatos({
    required this.ventanaBusquedaMeses,
    required this.advertencias,
  });

  factory CostoBeneficioMetadatos.fromJson(Map<String, dynamic> json) =>
      _$CostoBeneficioMetadatosFromJson(json);

  Map<String, dynamic> toJson() => _$CostoBeneficioMetadatosToJson(this);
}
