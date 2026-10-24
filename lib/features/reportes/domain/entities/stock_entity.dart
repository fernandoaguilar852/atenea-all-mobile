import 'common_entities.dart';

class StockEntity {
  final EncabezadoEntity encabezado;
  final List<StockRowEntity> productos;
  final StockResumenEntity resumen;
  final PaginacionEntity? pagination;

  const StockEntity({
    required this.encabezado,
    required this.productos,
    required this.resumen,
    this.pagination,
  });
}

class StockRowEntity {
  final int productoId;
  final String nombreProducto;
  final String? codigoBarras;
  final String? unidadMedida;
  final int stockActual;
  final int? stockDisponible;
  final int stockMinimo;
  final bool necesitaReposicion;
  final double precioVenta;
  final bool activo;

  const StockRowEntity({
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
}

class StockResumenEntity {
  final int totalProductos;
  final int productosConStockBajo;
  final double valorTotalInventario;

  const StockResumenEntity({
    required this.totalProductos,
    required this.productosConStockBajo,
    required this.valorTotalInventario,
  });
}
