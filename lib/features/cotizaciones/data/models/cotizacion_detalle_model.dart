import 'package:json_annotation/json_annotation.dart';
import 'cotizacion_model.dart';

part 'cotizacion_detalle_model.g.dart';

/// Datos de auditoría de la cotización (solo se usa el origen en la UI)
@JsonSerializable()
class AuditoriaModel {
  final String? ipOrigen;
  final String? userAgent;
  final String? origenRequest;

  const AuditoriaModel({
    this.ipOrigen,
    this.userAgent,
    this.origenRequest,
  });

  factory AuditoriaModel.fromJson(Map<String, dynamic> json) =>
      _$AuditoriaModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuditoriaModelToJson(this);
}

/// Línea (producto) de una cotización
@JsonSerializable()
class CotizacionLineaModel {
  final int cotizacionDetalleId;
  final int? productoId;
  final String nombreProducto;
  final String? descripcion;
  final double cantidad;
  final double precioUnitario;
  final double subtotal;
  final double descuentoValor;
  final String? codigoImpuesto;
  final double valorImpuesto;
  final double totalLinea;
  final String? observacionLinea;
  final String? createdAt;

  const CotizacionLineaModel({
    required this.cotizacionDetalleId,
    this.productoId,
    required this.nombreProducto,
    this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    required this.descuentoValor,
    this.codigoImpuesto,
    required this.valorImpuesto,
    required this.totalLinea,
    this.observacionLinea,
    this.createdAt,
  });

  factory CotizacionLineaModel.fromJson(Map<String, dynamic> json) =>
      _$CotizacionLineaModelFromJson(json);

  Map<String, dynamic> toJson() => _$CotizacionLineaModelToJson(this);
}

/// DTO/Model del detalle completo de una cotización
/// Reutiliza ConsumidorModel y TotalesModel del listado
@JsonSerializable()
class CotizacionDetalleModel {
  final int cotizacionId;
  final int clienteId;
  final String numeroCotizacion;
  final ConsumidorModel consumidor;
  final String fechaCotizacion; // ISO date string
  final String fechaValidez; // ISO date string
  final int diasValidez;
  final bool estaVencida;
  final TotalesModel totales;
  final String? observacion;
  final AuditoriaModel? auditoria;
  final String createdAt;
  final String? updatedAt;
  @JsonKey(defaultValue: <CotizacionLineaModel>[])
  final List<CotizacionLineaModel> detalles;

  const CotizacionDetalleModel({
    required this.cotizacionId,
    required this.clienteId,
    required this.numeroCotizacion,
    required this.consumidor,
    required this.fechaCotizacion,
    required this.fechaValidez,
    required this.diasValidez,
    required this.estaVencida,
    required this.totales,
    this.observacion,
    this.auditoria,
    required this.createdAt,
    this.updatedAt,
    required this.detalles,
  });

  factory CotizacionDetalleModel.fromJson(Map<String, dynamic> json) =>
      _$CotizacionDetalleModelFromJson(json);

  Map<String, dynamic> toJson() => _$CotizacionDetalleModelToJson(this);
}

/// Respuesta de la API para el detalle de una cotización
@JsonSerializable()
class CotizacionDetalleResponse {
  final CotizacionDetalleModel data;

  const CotizacionDetalleResponse({required this.data});

  factory CotizacionDetalleResponse.fromJson(Map<String, dynamic> json) =>
      _$CotizacionDetalleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CotizacionDetalleResponseToJson(this);
}
