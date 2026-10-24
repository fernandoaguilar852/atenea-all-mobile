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
  final String nombreProducto;
  final int cantidadConsumida;
  final String? unidadMedida;
  final int stockActual;
  final int stockMinimo;
  final bool necesitaReposicion;
  final int? numeroMovimientos;

  const InventarioRowEntity({
    required this.productoId,
    required this.nombreProducto,
    required this.cantidadConsumida,
    this.unidadMedida,
    required this.stockActual,
    required this.stockMinimo,
    required this.necesitaReposicion,
    this.numeroMovimientos,
  });
}

class InventarioResumenEntity {
  final int totalProductos;
  final int? totalMovimientos;
  final int productosConStockBajo;

  const InventarioResumenEntity({
    required this.totalProductos,
    this.totalMovimientos,
    required this.productosConStockBajo,
  });
}
