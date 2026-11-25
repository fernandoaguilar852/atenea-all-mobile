/// Línea (producto) de una cotización
class CotizacionLineaEntity {
  final int cotizacionDetalleId;
  final int? productoId;
  final String nombreProducto;
  final String? descripcion;
  final double cantidad;
  final double precioUnitario;
  final double subtotal;
  final double descuentoValor;
  final double valorImpuesto;
  final double totalLinea;
  final String? observacionLinea;

  const CotizacionLineaEntity({
    required this.cotizacionDetalleId,
    this.productoId,
    required this.nombreProducto,
    this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    required this.descuentoValor,
    required this.valorImpuesto,
    required this.totalLinea,
    this.observacionLinea,
  });
}

/// Entidad de dominio para el detalle completo de una Cotización
class CotizacionDetalleEntity {
  final int cotizacionId;
  final int clienteId;
  final String numeroCotizacion;
  final String consumidorNombre;
  final String? consumidorIdentificacion;
  final String? consumidorEmail;
  final String? consumidorTelefono;
  final DateTime fechaCotizacion;
  final DateTime fechaValidez;
  final int diasValidez;
  final bool estaVencida;
  final double subtotalSinImpuestos;
  final double totalDescuentos;
  final double totalImpuestos;
  final double total;
  final String? observacion;
  final String? origen;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<CotizacionLineaEntity> detalles;

  const CotizacionDetalleEntity({
    required this.cotizacionId,
    required this.clienteId,
    required this.numeroCotizacion,
    required this.consumidorNombre,
    this.consumidorIdentificacion,
    this.consumidorEmail,
    this.consumidorTelefono,
    required this.fechaCotizacion,
    required this.fechaValidez,
    required this.diasValidez,
    required this.estaVencida,
    required this.subtotalSinImpuestos,
    required this.totalDescuentos,
    required this.totalImpuestos,
    required this.total,
    this.observacion,
    this.origen,
    required this.createdAt,
    this.updatedAt,
    required this.detalles,
  });
}
