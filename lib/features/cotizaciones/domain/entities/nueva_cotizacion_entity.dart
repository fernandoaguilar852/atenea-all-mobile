/// Redondea a 2 decimales (evita resultados como 2707.4999999)
double _redondear(double valor) => (valor * 100).roundToDouble() / 100;

/// Línea de una cotización que se va a crear.
///
/// Los valores calculados siguen la misma lógica del API:
///   subtotal      = cantidad x precio unitario
///   descuento     = subtotal x % descuento
///   impuesto      = (subtotal - descuento) x % IVA
///   total línea   = subtotal - descuento + impuesto
class NuevaLineaCotizacion {
  final int productoId;
  final String productoNombre;
  final double cantidad;
  final double precioUnitario;
  final double descuentoPorcentaje;

  /// IVA del producto (no editable en el formulario)
  final double porcentajeImpuesto;

  /// Id de la línea ya guardada en el servidor. Es null para líneas nuevas.
  /// (Solo se usa al editar una cotización.)
  final int? cotizacionDetalleId;

  /// Observación de la línea (se conserva al editar)
  final String? observacionLinea;

  const NuevaLineaCotizacion({
    required this.productoId,
    required this.productoNombre,
    required this.cantidad,
    required this.precioUnitario,
    this.descuentoPorcentaje = 0,
    this.porcentajeImpuesto = 0,
    this.cotizacionDetalleId,
    this.observacionLinea,
  });

  /// true si la línea ya existe en el servidor (viene de una cotización guardada)
  bool get estaGuardada => cotizacionDetalleId != null;

  /// Copia de la línea con otros valores editables (el producto y el IVA no
  /// cambian: para otro producto se elimina la línea y se agrega una nueva)
  NuevaLineaCotizacion copyWith({
    double? cantidad,
    double? precioUnitario,
    double? descuentoPorcentaje,
  }) {
    return NuevaLineaCotizacion(
      productoId: productoId,
      productoNombre: productoNombre,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      descuentoPorcentaje: descuentoPorcentaje ?? this.descuentoPorcentaje,
      porcentajeImpuesto: porcentajeImpuesto,
      cotizacionDetalleId: cotizacionDetalleId,
      observacionLinea: observacionLinea,
    );
  }

  double get subtotal => _redondear(cantidad * precioUnitario);

  double get descuentoValor =>
      _redondear(subtotal * descuentoPorcentaje / 100);

  double get baseImpuesto => subtotal - descuentoValor;

  double get valorImpuesto =>
      _redondear(baseImpuesto * porcentajeImpuesto / 100);

  double get totalLinea => _redondear(baseImpuesto + valorImpuesto);

  /// "IVA" si el producto tiene impuesto, null si no
  String? get codigoImpuesto => porcentajeImpuesto > 0 ? 'IVA' : null;
}

/// Cotización que se va a crear: datos del cliente y sus líneas.
/// Los totales se calculan aquí a partir de las líneas, para que sean los
/// mismos en pantalla y en lo que se envía al API.
class NuevaCotizacion {
  final String consumidorNombre;
  final String consumidorIdentificacion;
  final String? consumidorEmail;
  final String? consumidorTelefono;
  final List<NuevaLineaCotizacion> lineas;

  const NuevaCotizacion({
    required this.consumidorNombre,
    required this.consumidorIdentificacion,
    this.consumidorEmail,
    this.consumidorTelefono,
    required this.lineas,
  });

  double get subtotalSinImpuestos =>
      _redondear(lineas.fold(0.0, (sum, l) => sum + l.subtotal));

  double get totalDescuentos =>
      _redondear(lineas.fold(0.0, (sum, l) => sum + l.descuentoValor));

  double get totalImpuestos =>
      _redondear(lineas.fold(0.0, (sum, l) => sum + l.valorImpuesto));

  /// Todos los impuestos de esta pantalla son IVA
  double get totalIva => totalImpuestos;

  double get totalInc => 0;

  double get totalIca => 0;

  double get total => _redondear(
        subtotalSinImpuestos - totalDescuentos + totalImpuestos,
      );
}

/// Resultado de crear la cabecera de una cotización
class CotizacionCreadaEntity {
  final int cotizacionId;
  final String numeroCotizacion;

  const CotizacionCreadaEntity({
    required this.cotizacionId,
    required this.numeroCotizacion,
  });
}
