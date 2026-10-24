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
  @JsonKey(name: 'fechaEmision', defaultValue: '')
  final String fechaVenta;
  @JsonKey(defaultValue: '')
  final String numeroFactura;
  @JsonKey(name: 'consumidorNombre', defaultValue: '')
  final String nombreCliente;
  @JsonKey(name: 'consumidorIdentificacion', defaultValue: '')
  final String? documentoCliente;
  @JsonKey(defaultValue: '')
  final String? emailCliente;
  @JsonKey(defaultValue: '')
  final String? telefonoCliente;
  @JsonKey(defaultValue: '')
  final String? nombreCajero;
  @JsonKey(defaultValue: '')
  final String? nombreCaja;
  @JsonKey(name: 'subtotalSinImpuestos', defaultValue: 0.0)
  final double subtotal;
  @JsonKey(name: 'totalDescuentos', defaultValue: 0.0)
  final double descuento;
  @JsonKey(name: 'totalImpuestos', defaultValue: 0.0)
  final double iva;
  @JsonKey(defaultValue: 0.0)
  final double total;
  @JsonKey(defaultValue: '')
  final String formaPago;
  @JsonKey(name: 'estado', defaultValue: '')
  final String estadoVenta;
  final List<VentaDetalleLinea> detalles;

  VentaDetalleRow({
    required this.ventaId,
    required this.fechaVenta,
    required this.numeroFactura,
    required this.nombreCliente,
    this.documentoCliente = '',
    this.emailCliente = '',
    this.telefonoCliente = '',
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

  factory VentaDetalleRow.fromJson(Map<String, dynamic> json) =>
      _$VentaDetalleRowFromJson(json);

  Map<String, dynamic> toJson() => _$VentaDetalleRowToJson(this);
}

@JsonSerializable()
class VentaDetalleLinea {
  final int productoId;
  @JsonKey(name: 'productoNombre', defaultValue: '')
  final String nombreProducto;
  @JsonKey(defaultValue: '')
  final String? codigoBarras;
  @JsonKey(defaultValue: 0)
  final int cantidad;
  @JsonKey(defaultValue: 0.0)
  final double precioUnitario;
  @JsonKey(name: 'descuentoValor', defaultValue: 0.0)
  final double descuento;
  @JsonKey(defaultValue: 0.0)
  final double subtotal;
  @JsonKey(name: 'valorImpuesto', defaultValue: 0.0)
  final double iva;
  @JsonKey(name: 'totalLinea', defaultValue: 0.0)
  final double total;

  VentaDetalleLinea({
    required this.productoId,
    required this.nombreProducto,
    this.codigoBarras = '',
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
  @JsonKey(defaultValue: 0)
  final int totalVentas;
  @JsonKey(name: 'subtotalGeneral', defaultValue: 0.0)
  final double totalSubtotal;
  @JsonKey(name: 'descuentosGeneral', defaultValue: 0.0)
  final double totalDescuento;
  @JsonKey(name: 'impuestosGeneral', defaultValue: 0.0)
  final double totalIVA;
  @JsonKey(defaultValue: 0.0)
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
