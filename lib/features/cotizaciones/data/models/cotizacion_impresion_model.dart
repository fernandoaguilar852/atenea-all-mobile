import 'package:json_annotation/json_annotation.dart';
import 'cotizacion_model.dart';

part 'cotizacion_impresion_model.g.dart';

/// El endpoint de impresión envía los números como texto ("34000.00", "1.000").
/// Estos convertidores aceptan texto o número y nunca fallan.
double _toDouble(Object? value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

double? _toDoubleOrNull(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

/// Ciudad del negocio
@JsonSerializable()
class EncabezadoCiudadModel {
  final String? nombre;
  final String? departamento;

  const EncabezadoCiudadModel({this.nombre, this.departamento});

  factory EncabezadoCiudadModel.fromJson(Map<String, dynamic> json) =>
      _$EncabezadoCiudadModelFromJson(json);

  Map<String, dynamic> toJson() => _$EncabezadoCiudadModelToJson(this);
}

/// Datos del negocio que emite la cotización (encabezado del PDF)
@JsonSerializable()
class EncabezadoModel {
  final String nombre;
  final String? razonSocial;
  final String? nit;
  final String? digitoVerificacion;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? logoUrl;
  final EncabezadoCiudadModel? ciudad;

  const EncabezadoModel({
    required this.nombre,
    this.razonSocial,
    this.nit,
    this.digitoVerificacion,
    this.telefono,
    this.email,
    this.direccion,
    this.logoUrl,
    this.ciudad,
  });

  factory EncabezadoModel.fromJson(Map<String, dynamic> json) =>
      _$EncabezadoModelFromJson(json);

  Map<String, dynamic> toJson() => _$EncabezadoModelToJson(this);
}

/// Datos básicos de la cotización para impresión
/// Reutiliza ConsumidorModel del listado
@JsonSerializable()
class ImpresionCotizacionModel {
  final int cotizacionId;
  final String numeroCotizacion;
  final ConsumidorModel consumidor;
  final String fechaCotizacion; // ISO date string
  final String? fechaValidez; // yyyy-MM-dd
  final String? observacion;

  const ImpresionCotizacionModel({
    required this.cotizacionId,
    required this.numeroCotizacion,
    required this.consumidor,
    required this.fechaCotizacion,
    this.fechaValidez,
    this.observacion,
  });

  factory ImpresionCotizacionModel.fromJson(Map<String, dynamic> json) =>
      _$ImpresionCotizacionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImpresionCotizacionModelToJson(this);
}

/// Producto asociado a una línea
@JsonSerializable()
class ImpresionProductoModel {
  final int? productoId;
  final String? nombre;
  final String? codigoExterno;
  final String? unidadMedida;
  final String? sigla;

  const ImpresionProductoModel({
    this.productoId,
    this.nombre,
    this.codigoExterno,
    this.unidadMedida,
    this.sigla,
  });

  factory ImpresionProductoModel.fromJson(Map<String, dynamic> json) =>
      _$ImpresionProductoModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImpresionProductoModelToJson(this);
}

/// Línea de la cotización para impresión (números llegan como texto)
@JsonSerializable()
class ImpresionLineaModel {
  final int cotizacionDetalleId;
  final int? productoId;
  final String? descripcion;
  @JsonKey(fromJson: _toDouble)
  final double cantidad;
  @JsonKey(fromJson: _toDouble)
  final double precioUnitario;
  @JsonKey(fromJson: _toDouble)
  final double subtotal;
  @JsonKey(fromJson: _toDouble)
  final double descuentoValor;
  @JsonKey(fromJson: _toDoubleOrNull)
  final double? descuentoPorcentaje;
  @JsonKey(fromJson: _toDoubleOrNull)
  final double? porcentajeImpuesto;
  @JsonKey(fromJson: _toDouble)
  final double valorImpuesto;
  @JsonKey(fromJson: _toDouble)
  final double totalLinea;
  final String? observacionLinea;
  final ImpresionProductoModel? producto;

  const ImpresionLineaModel({
    required this.cotizacionDetalleId,
    this.productoId,
    this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    required this.descuentoValor,
    this.descuentoPorcentaje,
    this.porcentajeImpuesto,
    required this.valorImpuesto,
    required this.totalLinea,
    this.observacionLinea,
    this.producto,
  });

  factory ImpresionLineaModel.fromJson(Map<String, dynamic> json) =>
      _$ImpresionLineaModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImpresionLineaModelToJson(this);
}

/// Totales para impresión (números llegan como texto)
@JsonSerializable()
class ImpresionTotalesModel {
  @JsonKey(fromJson: _toDouble)
  final double subtotalSinImpuestos;
  @JsonKey(fromJson: _toDouble)
  final double totalDescuentos;
  @JsonKey(fromJson: _toDouble)
  final double totalImpuestos;
  @JsonKey(fromJson: _toDouble)
  final double totalIva;
  @JsonKey(fromJson: _toDouble)
  final double totalInc;
  @JsonKey(fromJson: _toDouble)
  final double totalIca;
  @JsonKey(fromJson: _toDouble)
  final double total;

  const ImpresionTotalesModel({
    required this.subtotalSinImpuestos,
    required this.totalDescuentos,
    required this.totalImpuestos,
    required this.totalIva,
    required this.totalInc,
    required this.totalIca,
    required this.total,
  });

  factory ImpresionTotalesModel.fromJson(Map<String, dynamic> json) =>
      _$ImpresionTotalesModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImpresionTotalesModelToJson(this);
}

/// Textos del pie de página configurados por el negocio
@JsonSerializable()
class PiePaginaModel {
  final String? facturaPiePagina;
  final String? agradecimiento;
  final String? notas;
  final String? terminosCondiciones;

  const PiePaginaModel({
    this.facturaPiePagina,
    this.agradecimiento,
    this.notas,
    this.terminosCondiciones,
  });

  factory PiePaginaModel.fromJson(Map<String, dynamic> json) =>
      _$PiePaginaModelFromJson(json);

  Map<String, dynamic> toJson() => _$PiePaginaModelToJson(this);
}

/// Data completa para generar el PDF de la cotización
@JsonSerializable()
class ImpresionDataModel {
  final EncabezadoModel encabezado;
  final ImpresionCotizacionModel cotizacion;
  @JsonKey(defaultValue: <ImpresionLineaModel>[])
  final List<ImpresionLineaModel> detalle;
  final ImpresionTotalesModel totales;
  final PiePaginaModel? piePagina;

  const ImpresionDataModel({
    required this.encabezado,
    required this.cotizacion,
    required this.detalle,
    required this.totales,
    this.piePagina,
  });

  factory ImpresionDataModel.fromJson(Map<String, dynamic> json) =>
      _$ImpresionDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImpresionDataModelToJson(this);
}

/// Respuesta de la API para la impresión de una cotización
@JsonSerializable()
class CotizacionImpresionResponse {
  final ImpresionDataModel data;

  const CotizacionImpresionResponse({required this.data});

  factory CotizacionImpresionResponse.fromJson(Map<String, dynamic> json) =>
      _$CotizacionImpresionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CotizacionImpresionResponseToJson(this);
}
