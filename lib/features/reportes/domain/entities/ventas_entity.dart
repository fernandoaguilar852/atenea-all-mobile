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
  final String nombreProducto;
  final String nombreCategoria;
  final int cantidadVendida;
  final double precioVentaUnitario;
  final double subtotal;
  final double? descuentosAplicados;
  final double? impuestosAplicados;
  final double totalVentas;
  final int? numeroTransacciones;

  const VentaRowEntity({
    required this.productoId,
    required this.nombreProducto,
    required this.nombreCategoria,
    required this.cantidadVendida,
    required this.precioVentaUnitario,
    required this.subtotal,
    this.descuentosAplicados,
    this.impuestosAplicados,
    required this.totalVentas,
    this.numeroTransacciones,
  });
}

/// Resumen del reporte de ventas
class VentasResumenEntity {
  final int totalProductosVendidos;
  final int totalTransacciones;
  final double subtotalGeneral;
  final double descuentosGeneral;
  final double impuestosGeneral;
  final double totalGeneral;

  const VentasResumenEntity({
    required this.totalProductosVendidos,
    required this.totalTransacciones,
    required this.subtotalGeneral,
    required this.descuentosGeneral,
    required this.impuestosGeneral,
    required this.totalGeneral,
  });
}
