import 'common_entities.dart';

class InventarioEntity {
  final EncabezadoEntity encabezado;
  final List<InventarioRowEntity> productos;
  final InventarioResumenEntity resumen;
  final PaginacionEntity? pagination;

  const InventarioEntity({
    required this.encabezado,
    required this.productos,
    required this.resumen,
    this.pagination,
  });
}

class InventarioRowEntity {
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

  const InventarioRowEntity({
    required this.productoId,
    required this.codigoBarras,
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
}

class InventarioResumenEntity {
  final int totalProductos;
  final int totalCantidadConsumida;
  final double costoTotalInventario;
  final int productosConStockBajo;

  const InventarioResumenEntity({
    required this.totalProductos,
    required this.totalCantidadConsumida,
    required this.costoTotalInventario,
    required this.productosConStockBajo,
  });
}
