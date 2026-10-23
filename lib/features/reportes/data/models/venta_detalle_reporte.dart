import 'package:json_annotation/json_annotation.dart';
import 'reporte_encabezado.dart';

part 'venta_detalle_reporte.g.dart';

@JsonSerializable()
class VentaDetalleReporte {
  final ReporteEncabezado encabezado;
  final List<VentaDetalleRow> ventas;
  final VentaDetalleResumen resumen;
  final ReportePagination? pagination;

  VentaDetalleReporte({
    required this.encabezado,
    required this.ventas,
    required this.resumen,
    this.pagination,
  });

  factory VentaDetalleReporte.fromJson(Map<String, dynamic> json) =>
      _$VentaDetalleReporteFromJson(json);

  Map<String, dynamic> toJson() => _$VentaDetalleReporteToJson(this);
}

@JsonSerializable()
class VentaDetalleRow {
  final int ventaId;
  final String fechaVenta;
  final String numeroFactura;
  final String nombreCliente;
  final String documentoCliente;
  final String emailCliente;
  final String telefonoCliente;
  final String nombreCajero;
  final String nombreCaja;
  final double subtotal;
  final double descuento;
  final double iva;
  final double total;
  final String formaPago;
  final String estadoVenta;
  final List<VentaDetalleLinea> detalles;

  VentaDetalleRow({
    required this.ventaId,
    required this.fechaVenta,
    required this.numeroFactura,
    required this.nombreCliente,
    required this.documentoCliente,
    required this.emailCliente,
    required this.telefonoCliente,
    required this.nombreCajero,
    required this.nombreCaja,
    required this.subtotal,
    required this.descuento,
    required this.iva,
    required this.total,
    required this.formaPago,
    required this.estadoVenta,
    required this.detalles,
  });

  factory VentaDetalleRow.fromJson(Map<String, dynamic> json) =>
      _$VentaDetalleRowFromJson(json);

  Map<String, dynamic> toJson() => _$VentaDetalleRowToJson(this);
}

@JsonSerializable()
class VentaDetalleLinea {
  final int productoId;
  final String nombreProducto;
  final String codigoBarras;
  final int cantidad;
  final double precioUnitario;
  final double descuento;
  final double subtotal;
  final double iva;
  final double total;

  VentaDetalleLinea({
    required this.productoId,
    required this.nombreProducto,
    required this.codigoBarras,
    required this.cantidad,
    required this.precioUnitario,
    required this.descuento,
    required this.subtotal,
    required this.iva,
    required this.total,
  });

  factory VentaDetalleLinea.fromJson(Map<String, dynamic> json) =>
      _$VentaDetalleLineaFromJson(json);

  Map<String, dynamic> toJson() => _$VentaDetalleLineaToJson(this);
}

@JsonSerializable()
class VentaDetalleResumen {
  final int totalVentas;
  final double totalSubtotal;
  final double totalDescuento;
  final double totalIVA;
  final double totalGeneral;

  VentaDetalleResumen({
    required this.totalVentas,
    required this.totalSubtotal,
    required this.totalDescuento,
    required this.totalIVA,
    required this.totalGeneral,
  });

  factory VentaDetalleResumen.fromJson(Map<String, dynamic> json) =>
      _$VentaDetalleResumenFromJson(json);

  Map<String, dynamic> toJson() => _$VentaDetalleResumenToJson(this);
}
