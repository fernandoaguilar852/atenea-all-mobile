import 'package:json_annotation/json_annotation.dart';
import 'reporte_encabezado.dart';

part 'inventario_reporte.g.dart';

@JsonSerializable()
class InventarioReporte {
  final ReporteEncabezado encabezado;
  final List<InventarioRow> productos;
  final InventarioResumen resumen;
  final ReportePagination? pagination;

  InventarioReporte({
    required this.encabezado,
    required this.productos,
    required this.resumen,
    this.pagination,
  });

  factory InventarioReporte.fromJson(Map<String, dynamic> json) =>
      _$InventarioReporteFromJson(json);

  Map<String, dynamic> toJson() => _$InventarioReporteToJson(this);
}

@JsonSerializable()
class InventarioRow {
  final int productoId;
  @JsonKey(name: 'productoNombre', defaultValue: '')
  final String nombreProducto;
  @JsonKey(defaultValue: 0)
  final int cantidadConsumida;
  @JsonKey(defaultValue: '')
  final String? unidadMedida;
  @JsonKey(defaultValue: 0)
  final int stockActual;
  @JsonKey(defaultValue: 0)
  final int stockMinimo;
  @JsonKey(name: 'requiereReposicion', defaultValue: false)
  final bool necesitaReposicion;
  @JsonKey(defaultValue: 0)
  final int? numeroMovimientos;

  InventarioRow({
    required this.productoId,
    required this.nombreProducto,
    required this.cantidadConsumida,
    this.unidadMedida,
    required this.stockActual,
    required this.stockMinimo,
    required this.necesitaReposicion,
    this.numeroMovimientos,
  });

  factory InventarioRow.fromJson(Map<String, dynamic> json) =>
      _$InventarioRowFromJson(json);

  Map<String, dynamic> toJson() => _$InventarioRowToJson(this);
}

@JsonSerializable()
class InventarioResumen {
  @JsonKey(name: 'totalProductosConsumidos', defaultValue: 0)
  final int totalProductos;
  @JsonKey(defaultValue: 0)
  final int? totalMovimientos;
  @JsonKey(name: 'itemsRequierenReposicion', defaultValue: 0)
  final int productosConStockBajo;

  InventarioResumen({
    required this.totalProductos,
    this.totalMovimientos,
    required this.productosConStockBajo,
  });

  factory InventarioResumen.fromJson(Map<String, dynamic> json) =>
      _$InventarioResumenFromJson(json);

  Map<String, dynamic> toJson() => _$InventarioResumenToJson(this);
}
