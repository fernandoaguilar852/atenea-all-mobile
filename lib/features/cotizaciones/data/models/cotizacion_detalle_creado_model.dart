import 'package:json_annotation/json_annotation.dart';

part 'cotizacion_detalle_creado_model.g.dart';

/// Detalle devuelto por la API al crear una línea de cotización.
/// (La respuesta de creación no trae el nombre del producto, por eso no se
/// reutiliza CotizacionLineaModel.)
@JsonSerializable()
class CotizacionDetalleCreadoModel {
  final int cotizacionDetalleId;
  final int cotizacionId;
  final int? productoId;
  final double cantidad;
  final double precioUnitario;
  final double subtotal;
  final double descuentoValor;
  final double? descuentoPorcentaje;
  final String? codigoImpuesto;
  final double? porcentajeImpuesto;
  final double valorImpuesto;
  final double totalLinea;
  final String? observacionLinea;

  const CotizacionDetalleCreadoModel({
    required this.cotizacionDetalleId,
    required this.cotizacionId,
    this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    required this.descuentoValor,
    this.descuentoPorcentaje,
    this.codigoImpuesto,
    this.porcentajeImpuesto,
    required this.valorImpuesto,
    required this.totalLinea,
    this.observacionLinea,
  });

  factory CotizacionDetalleCreadoModel.fromJson(Map<String, dynamic> json) =>
      _$CotizacionDetalleCreadoModelFromJson(json);

  Map<String, dynamic> toJson() => _$CotizacionDetalleCreadoModelToJson(this);
}

/// Respuesta de la API al crear un detalle de cotización
@JsonSerializable()
class CotizacionDetalleCreadoResponse {
  final CotizacionDetalleCreadoModel data;

  const CotizacionDetalleCreadoResponse({required this.data});

  factory CotizacionDetalleCreadoResponse.fromJson(Map<String, dynamic> json) =>
      _$CotizacionDetalleCreadoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CotizacionDetalleCreadoResponseToJson(this);
}
