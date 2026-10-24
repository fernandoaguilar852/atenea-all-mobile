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
  final String? codigoBarras;
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

  const StockRowEntity({
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
}

class StockResumenEntity {
  final int totalProductos;
  final int productosActivos;
  final int productosInactivos;
  final int productosConStockBajo;
  final int productosAgotados;
  final double valorTotalInventario;

  const StockResumenEntity({
    required this.totalProductos,
    required this.productosActivos,
    required this.productosInactivos,
    required this.productosConStockBajo,
    required this.productosAgotados,
    required this.valorTotalInventario,
  });
}
