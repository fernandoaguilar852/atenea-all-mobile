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
  final String? codigoBarras;
  final String nombreProducto;
  final int categoriaId;
  final String nombreCategoria;
  final int cantidadConsumida;
  final int stockActual;
  final int stockMinimo;
  final bool necesitaReposicion;
  final double costoUnitario;
  final double costoTotal;

  InventarioRow({
    required this.productoId,
    this.codigoBarras,
    required this.nombreProducto,
    required this.categoriaId,
    required this.nombreCategoria,
    required this.cantidadConsumida,
    required this.stockActual,
    required this.stockMinimo,
    required this.necesitaReposicion,
    required this.costoUnitario,
    required this.costoTotal,
  });

  factory InventarioRow.fromJson(Map<String, dynamic> json) =>
      _$InventarioRowFromJson(json);

  Map<String, dynamic> toJson() => _$InventarioRowToJson(this);
}

@JsonSerializable()
class InventarioResumen {
  final int totalProductos;
  final int totalCantidadConsumida;
  final double costoTotalInventario;
  final int productosConStockBajo;

  InventarioResumen({
    required this.totalProductos,
    required this.totalCantidadConsumida,
    required this.costoTotalInventario,
    required this.productosConStockBajo,
  });

  factory InventarioResumen.fromJson(Map<String, dynamic> json) =>
      _$InventarioResumenFromJson(json);

  Map<String, dynamic> toJson() => _$InventarioResumenToJson(this);
}
