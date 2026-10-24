import 'common_entities.dart';

/// Reporte de ventas por producto
class VentasEntity {
  final EncabezadoEntity encabezado;
  final List<VentaRowEntity> reporteVentas;
  final VentasResumenEntity resumen;
  final PaginacionEntity? pagination;

  const VentasEntity({
    required this.encabezado,
    required this.reporteVentas,
    required this.resumen,
    this.pagination,
  });
}

/// Fila de venta por producto
class VentaRowEntity {
  final int productoId;
  final String codigoBarras;
  final String nombreProducto;
  final int categoriaId;
  final String nombreCategoria;
  final double precioVentaUnitario;
  final int cantidadVendida;
  final double totalVentas;

  const VentaRowEntity({
    required this.productoId,
    required this.codigoBarras,
    required this.nombreProducto,
    required this.categoriaId,
    required this.nombreCategoria,
    required this.precioVentaUnitario,
    required this.cantidadVendida,
    required this.totalVentas,
  });
}

/// Resumen del reporte de ventas
class VentasResumenEntity {
  final int totalProductosVendidos;
  final int totalCantidadVendida;
  final double totalVentas;

  const VentasResumenEntity({
    required this.totalProductosVendidos,
    required this.totalCantidadVendida,
    required this.totalVentas,
  });
}
