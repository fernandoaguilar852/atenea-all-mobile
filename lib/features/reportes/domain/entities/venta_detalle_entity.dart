import 'common_entities.dart';

class VentaDetalleEntity {
  final EncabezadoEntity encabezado;
  final List<VentaDetalleRowEntity> ventas;
  final VentaDetalleResumenEntity resumen;
  final PaginacionEntity? pagination;

  const VentaDetalleEntity({
    required this.encabezado,
    required this.ventas,
    required this.resumen,
    this.pagination,
  });
}

class VentaDetalleRowEntity {
  final int ventaId;
  final String fechaVenta;
  final String numeroFactura;
  final String nombreCliente;
  final String? documentoCliente;
  final String? emailCliente;
  final String? telefonoCliente;
  final String? nombreCajero;
  final String? nombreCaja;
  final double subtotal;
  final double descuento;
  final double iva;
  final double total;
  final String formaPago;
  final String estadoVenta;
  final List<VentaDetalleLineaEntity> detalles;

  const VentaDetalleRowEntity({
    required this.ventaId,
    required this.fechaVenta,
    required this.numeroFactura,
    required this.nombreCliente,
    this.documentoCliente,
    this.emailCliente,
    this.telefonoCliente,
    this.nombreCajero,
    this.nombreCaja,
    required this.subtotal,
    required this.descuento,
    required this.iva,
    required this.total,
    required this.formaPago,
    required this.estadoVenta,
    required this.detalles,
  });
}

class VentaDetalleLineaEntity {
  final int productoId;
  final String nombreProducto;
  final String? codigoBarras;
  final int cantidad;
  final double precioUnitario;
  final double descuento;
  final double subtotal;
  final double iva;
  final double total;

  const VentaDetalleLineaEntity({
    required this.productoId,
    required this.nombreProducto,
    this.codigoBarras,
    required this.cantidad,
    required this.precioUnitario,
    required this.descuento,
    required this.subtotal,
    required this.iva,
    required this.total,
  });
}

class VentaDetalleResumenEntity {
  final int totalVentas;
  final double totalSubtotal;
  final double totalDescuento;
  final double totalIVA;
  final double totalGeneral;

  const VentaDetalleResumenEntity({
    required this.totalVentas,
    required this.totalSubtotal,
    required this.totalDescuento,
    required this.totalIVA,
    required this.totalGeneral,
  });
}
