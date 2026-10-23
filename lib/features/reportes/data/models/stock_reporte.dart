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
  final String codigoBarras;
  final String nombreProducto;
  final int categoriaId;
  final String nombreCategoria;
  final int stockActual;
  final int stockMinimo;
  final int stockMaximo;
  final bool necesitaReposicion;
  final bool activo;
  final double precioVenta;
  final double costoUnitario;
  final double valorInventario;

  StockRow({
    required this.productoId,
    required this.codigoBarras,
    required this.nombreProducto,
    required this.categoriaId,
    required this.nombreCategoria,
    required this.stockActual,
    required this.stockMinimo,
    required this.stockMaximo,
    required this.necesitaReposicion,
    required this.activo,
    required this.precioVenta,
    required this.costoUnitario,
    required this.valorInventario,
  });

  factory StockRow.fromJson(Map<String, dynamic> json) =>
      _$StockRowFromJson(json);

  Map<String, dynamic> toJson() => _$StockRowToJson(this);
}

@JsonSerializable()
class StockResumen {
  final int totalProductos;
  final int productosActivos;
  final int productosInactivos;
  final int productosConStockBajo;
  final int productosAgotados;
  final double valorTotalInventario;

  StockResumen({
    required this.totalProductos,
    required this.productosActivos,
    required this.productosInactivos,
    required this.productosConStockBajo,
    required this.productosAgotados,
    required this.valorTotalInventario,
  });

  factory StockResumen.fromJson(Map<String, dynamic> json) =>
      _$StockResumenFromJson(json);

  Map<String, dynamic> toJson() => _$StockResumenToJson(this);
}
