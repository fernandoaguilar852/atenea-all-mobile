import 'cotizacion_impresion_entity.dart';
import 'nueva_cotizacion_entity.dart';

/// Cotización ya guardada, lista para cargarse en el formulario de edición:
/// datos del cliente, observación y sus líneas (con id y porcentajes).
class CotizacionEditable {
  final int cotizacionId;
  final String numeroCotizacion;
  final String consumidorNombre;
  final String consumidorIdentificacion;
  final String? consumidorEmail;
  final String? consumidorTelefono;
  final String? observacion;
  final List<NuevaLineaCotizacion> lineas;

  const CotizacionEditable({
    required this.cotizacionId,
    required this.numeroCotizacion,
    required this.consumidorNombre,
    required this.consumidorIdentificacion,
    this.consumidorEmail,
    this.consumidorTelefono,
    this.observacion,
    required this.lineas,
  });

  /// Arma la cotización editable a partir de los datos de impresión
  factory CotizacionEditable.fromImpresion(CotizacionImpresionEntity e) {
    return CotizacionEditable(
      cotizacionId: e.cotizacionId,
      numeroCotizacion: e.numeroCotizacion,
      consumidorNombre: e.consumidorNombre,
      consumidorIdentificacion: e.consumidorIdentificacion ?? '',
      consumidorEmail: e.consumidorEmail,
      consumidorTelefono: e.consumidorTelefono,
      observacion: e.observacion,
      lineas: e.lineas
          .map(
            (l) => NuevaLineaCotizacion(
              productoId: l.productoId ?? 0,
              productoNombre: l.descripcion,
              cantidad: l.cantidad,
              precioUnitario: l.precioUnitario,
              descuentoPorcentaje: l.descuentoPorcentaje,
              porcentajeImpuesto: l.porcentajeImpuesto,
              cotizacionDetalleId: l.cotizacionDetalleId,
              observacionLinea: l.observacionLinea,
            ),
          )
          .toList(),
    );
  }
}
