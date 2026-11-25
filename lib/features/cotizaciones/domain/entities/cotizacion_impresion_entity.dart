/// Línea de la cotización lista para imprimir
class ImpresionLineaEntity {
  final double cantidad;
  final String referencia;
  final String descripcion;
  final double precioUnitario;
  final double descuentoValor;
  final double porcentajeImpuesto;
  final double totalLinea;

  const ImpresionLineaEntity({
    required this.cantidad,
    required this.referencia,
    required this.descripcion,
    required this.precioUnitario,
    required this.descuentoValor,
    required this.porcentajeImpuesto,
    required this.totalLinea,
  });
}

/// Entidad de dominio con todos los datos para generar el PDF de una cotización
class CotizacionImpresionEntity {
  // Negocio (encabezado)
  final String empresaNombre;
  final String? empresaNit; // Ya con dígito de verificación (ej. 37810503-3)
  final String? empresaDireccion;
  final String? empresaTelefono;
  final String? empresaEmail;
  final String? empresaCiudad; // Ej. "Bucaramanga - Santander"
  final String? logoUrl;

  // Cotización
  final String numeroCotizacion;
  final DateTime fechaCotizacion;
  final DateTime? fechaValidez;
  final String? observacion;

  // Consumidor
  final String consumidorNombre;
  final String? consumidorIdentificacion;
  final String? consumidorTelefono;
  final String? consumidorEmail;

  // Líneas y totales
  final List<ImpresionLineaEntity> lineas;
  final double subtotal;
  final double totalDescuentos;
  final double totalIva;
  final double total;

  // Pie de página
  final String? facturaPiePagina;
  final String? agradecimiento;
  final String? notas;
  final String? terminosCondiciones;

  const CotizacionImpresionEntity({
    required this.empresaNombre,
    this.empresaNit,
    this.empresaDireccion,
    this.empresaTelefono,
    this.empresaEmail,
    this.empresaCiudad,
    this.logoUrl,
    required this.numeroCotizacion,
    required this.fechaCotizacion,
    this.fechaValidez,
    this.observacion,
    required this.consumidorNombre,
    this.consumidorIdentificacion,
    this.consumidorTelefono,
    this.consumidorEmail,
    required this.lineas,
    required this.subtotal,
    required this.totalDescuentos,
    required this.totalIva,
    required this.total,
    this.facturaPiePagina,
    this.agradecimiento,
    this.notas,
    this.terminosCondiciones,
  });
}
