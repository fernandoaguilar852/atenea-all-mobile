import 'package:json_annotation/json_annotation.dart';
import 'reporte_encabezado.dart';

part 'stock_reporte.g.dart';

@JsonSerializable()
class StockReporte {
  final ReporteEncabezado encabezado;
  final List<StockRow> productos;
  final StockResumen resumen;
  final ReportePagination? pagination;

  StockReporte({
    required this.encabezado,
    required this.productos,
    required this.resumen,
    this.pagination,
  });

  factory StockReporte.fromJson(Map<String, dynamic> json) =>
      _$StockReporteFromJson(json);

  Map<String, dynamic> toJson() => _$StockReporteToJson(this);
}

@JsonSerializable()
class StockRow {
  final int productoId;
  @JsonKey(name: 'nombre', defaultValue: '')
  final String nombreProducto;
  @JsonKey(defaultValue: '')
  final String? codigoBarras;
  @JsonKey(defaultValue: '')
  final String? unidadMedida;
  @JsonKey(name: 'stockTotal', defaultValue: 0)
  final int stockActual;
  @JsonKey(defaultValue: 0)
  final int? stockDisponible;
  @JsonKey(defaultValue: 0)
  final int stockMinimo;
  @JsonKey(name: 'requiereReposicion', defaultValue: false)
  final bool necesitaReposicion;
  @JsonKey(name: 'precio', defaultValue: 0.0)
  final double precioVenta;
  @JsonKey(defaultValue: false)
  final bool activo;

  StockRow({
    required this.productoId,
    required this.nombreProducto,
    this.codigoBarras,
    this.unidadMedida,
    required this.stockActual,
    this.stockDisponible,
    required this.stockMinimo,
    required this.necesitaReposicion,
    required this.precioVenta,
    required this.activo,
  });

  factory StockRow.fromJson(Map<String, dynamic> json) =>
      _$StockRowFromJson(json);

  Map<String, dynamic> toJson() => _$StockRowToJson(this);
}

@JsonSerializable()
class StockResumen {
  @JsonKey(defaultValue: 0)
  final int totalProductos;
  @JsonKey(name: 'productosStockBajo', defaultValue: 0)
  final int productosConStockBajo;
  @JsonKey(name: 'valorInventario', defaultValue: 0.0)
  final double valorTotalInventario;

  StockResumen({
    required this.totalProductos,
    required this.productosConStockBajo,
    required this.valorTotalInventario,
  });

  factory StockResumen.fromJson(Map<String, dynamic> json) =>
      _$StockResumenFromJson(json);

  Map<String, dynamic> toJson() => _$StockResumenToJson(this);
}
