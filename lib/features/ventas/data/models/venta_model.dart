import 'package:json_annotation/json_annotation.dart';

part 'venta_model.g.dart';

@JsonSerializable()
class VentaPagoModel {
  @JsonKey(name: 'ventaPagoId')
  final int ventaPagoId;

  @JsonKey(name: 'ventaId')
  final int ventaId;

  @JsonKey(name: 'pagoId')
  final int pagoId;

  @JsonKey(name: 'valor', fromJson: _parseDouble)
  final double valor;

  @JsonKey(name: 'numeroComprobante')
  final String? numeroComprobante;

  @JsonKey(name: 'bancoId')
  final int? bancoId;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  const VentaPagoModel({
    required this.ventaPagoId,
    required this.ventaId,
    required this.pagoId,
    required this.valor,
    this.numeroComprobante,
    this.bancoId,
    required this.createdAt,
  });

  factory VentaPagoModel.fromJson(Map<String, dynamic> json) =>
      _$VentaPagoModelFromJson(json);

  Map<String, dynamic> toJson() => _$VentaPagoModelToJson(this);
}

@JsonSerializable()
class VentaDetalleModel {
  @JsonKey(name: 'ventaDetalleId')
  final int ventaDetalleId;

  @JsonKey(name: 'clienteId')
  final int clienteId;

  @JsonKey(name: 'ventaId')
  final int ventaId;

  @JsonKey(name: 'productoId')
  final int productoId;

  @JsonKey(name: 'productoNombre')
  final String productoNombre;

  @JsonKey(name: 'descripcion')
  final String? descripcion;

  @JsonKey(name: 'cantidad', fromJson: _parseDouble)
  final double cantidad;

  @JsonKey(name: 'precioUnitario', fromJson: _parseDouble)
  final double precioUnitario;

  @JsonKey(name: 'subtotal', fromJson: _parseDouble)
  final double subtotal;

  @JsonKey(name: 'descuentoValor', fromJson: _parseDouble)
  final double descuentoValor;

  @JsonKey(name: 'descuentoPorcentaje', fromJson: _parseDouble)
  final double descuentoPorcentaje;

  @JsonKey(name: 'codigoImpuesto')
  final String? codigoImpuesto;

  @JsonKey(name: 'porcentajeImpuesto', fromJson: _parseDouble)
  final double porcentajeImpuesto;

  @JsonKey(name: 'valorImpuesto', fromJson: _parseDouble)
  final double valorImpuesto;

  @JsonKey(name: 'totalLinea', fromJson: _parseDouble)
  final double totalLinea;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  const VentaDetalleModel({
    required this.ventaDetalleId,
    required this.clienteId,
    required this.ventaId,
    required this.productoId,
    required this.productoNombre,
    this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    required this.descuentoValor,
    required this.descuentoPorcentaje,
    this.codigoImpuesto,
    required this.porcentajeImpuesto,
    required this.valorImpuesto,
    required this.totalLinea,
    required this.createdAt,
  });

  factory VentaDetalleModel.fromJson(Map<String, dynamic> json) =>
      _$VentaDetalleModelFromJson(json);

  Map<String, dynamic> toJson() => _$VentaDetalleModelToJson(this);
}

@JsonSerializable()
class VentaModel {
  @JsonKey(name: 'ventaId')
  final int ventaId;

  @JsonKey(name: 'clienteId')
  final int clienteId;

  @JsonKey(name: 'consumidorId')
  final int? consumidorId;

  @JsonKey(name: 'consumidor')
  final ConsumidorModel? consumidor;

  @JsonKey(name: 'cajaId')
  final int? cajaId;

  @JsonKey(name: 'ordenServicioId')
  final int? ordenServicioId;

  @JsonKey(name: 'formaPago')
  final String? formaPago;

  @JsonKey(name: 'formaPagoId')
  final int? formaPagoId;

  @JsonKey(name: 'formaPagoNombre')
  final String? formaPagoNombre;

  @JsonKey(name: 'formaPagoTipo')
  final String? formaPagoTipo;

  @JsonKey(name: 'fechaVencimiento')
  final String? fechaVencimiento;

  @JsonKey(name: 'codigoVoucher')
  final String? codigoVoucher;

  // Montos - pueden venir como String desde la API
  @JsonKey(name: 'subtotalSinImpuestos', fromJson: _parseDouble)
  final double subtotalSinImpuestos;

  @JsonKey(name: 'totalDescuentos', fromJson: _parseDouble)
  final double totalDescuentos;

  @JsonKey(name: 'totalImpuestos', fromJson: _parseDouble)
  final double totalImpuestos;

  @JsonKey(name: 'totalIva', fromJson: _parseDouble)
  final double totalIva;

  @JsonKey(name: 'totalInc', fromJson: _parseDouble)
  final double totalInc;

  @JsonKey(name: 'totalIca', fromJson: _parseDouble)
  final double totalIca;

  @JsonKey(name: 'total', fromJson: _parseDouble)
  final double total;

  @JsonKey(name: 'porcentajeFinanciamiento', fromJson: _parseDoubleOrZero)
  final double porcentajeFinanciamiento;

  @JsonKey(name: 'valorFinanciamiento', fromJson: _parseDoubleOrZero)
  final double valorFinanciamiento;

  // Estado
  @JsonKey(name: 'estado')
  final String estado;

  @JsonKey(name: 'observacion')
  final String? observacion;

  // Facturación DIAN
  @JsonKey(name: 'tipoDocumento')
  final String? tipoDocumento;

  @JsonKey(name: 'prefijoFactura')
  final String? prefijoFactura;

  @JsonKey(name: 'numeroFactura')
  final String? numeroFactura;

  @JsonKey(name: 'fechaEmision')
  final String? fechaEmision;

  @JsonKey(name: 'cufe')
  final String? cufe;

  @JsonKey(name: 'qrCode')
  final String? qrCode;

  @JsonKey(name: 'estadoDian')
  final String? estadoDian;

  @JsonKey(name: 'dianTrackId')
  final String? dianTrackId;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  @JsonKey(name: 'pagos')
  final List<VentaPagoModel>? pagos;

  @JsonKey(name: 'detalles')
  final List<VentaDetalleModel>? detalles;

  const VentaModel({
    required this.ventaId,
    required this.clienteId,
    this.consumidorId,
    this.consumidor,
    this.cajaId,
    this.ordenServicioId,
    this.formaPago,
    this.formaPagoId,
    this.formaPagoNombre,
    this.formaPagoTipo,
    this.fechaVencimiento,
    this.codigoVoucher,
    required this.subtotalSinImpuestos,
    required this.totalDescuentos,
    required this.totalImpuestos,
    required this.totalIva,
    required this.totalInc,
    required this.totalIca,
    required this.total,
    required this.porcentajeFinanciamiento,
    required this.valorFinanciamiento,
    required this.estado,
    this.observacion,
    this.tipoDocumento,
    this.prefijoFactura,
    this.numeroFactura,
    this.fechaEmision,
    this.cufe,
    this.qrCode,
    this.estadoDian,
    this.dianTrackId,
    required this.createdAt,
    this.pagos,
    this.detalles,
  });

  factory VentaModel.fromJson(Map<String, dynamic> json) =>
      _$VentaModelFromJson(json);

  Map<String, dynamic> toJson() => _$VentaModelToJson(this);
}

/// Helper functions para parsear valores numéricos que pueden venir como String
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

double _parseDoubleOrZero(dynamic value) {
  return _parseDouble(value);
}

@JsonSerializable()
class ConsumidorModel {
  @JsonKey(name: 'consumidorId')
  final int consumidorId;

  @JsonKey(name: 'nombreRazonSocial')
  final String nombreRazonSocial;

  @JsonKey(name: 'numeroIdentificacion')
  final String numeroIdentificacion;

  @JsonKey(name: 'tipoIdentificacion')
  final String tipoIdentificacion;

  @JsonKey(name: 'direccion')
  final String? direccion;

  @JsonKey(name: 'telefono')
  final String? telefono;

  @JsonKey(name: 'email')
  final String? email;

  const ConsumidorModel({
    required this.consumidorId,
    required this.nombreRazonSocial,
    required this.numeroIdentificacion,
    required this.tipoIdentificacion,
    this.direccion,
    this.telefono,
    this.email,
  });

  factory ConsumidorModel.fromJson(Map<String, dynamic> json) =>
      _$ConsumidorModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConsumidorModelToJson(this);
}

/// Response para lista de ventas con paginación
@JsonSerializable()
class VentasResponse {
  @JsonKey(name: 'data')
  final VentasDataResponse data;

  @JsonKey(name: 'pagination')
  final PaginationResponse? pagination;

  const VentasResponse({
    required this.data,
    this.pagination,
  });

  factory VentasResponse.fromJson(Map<String, dynamic> json) =>
      _$VentasResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VentasResponseToJson(this);
}

@JsonSerializable()
class VentasDataResponse {
  @JsonKey(name: 'ventas')
  final List<VentaModel> ventas;

  const VentasDataResponse({required this.ventas});

  factory VentasDataResponse.fromJson(Map<String, dynamic> json) =>
      _$VentasDataResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VentasDataResponseToJson(this);
}

@JsonSerializable()
class PaginationResponse {
  @JsonKey(name: 'totalElement')
  final int totalElement;

  @JsonKey(name: 'pageSize')
  final int pageSize;

  @JsonKey(name: 'pageNumber')
  final int pageNumber;

  @JsonKey(name: 'hasMoreElements')
  final bool hasMoreElements;

  const PaginationResponse({
    required this.totalElement,
    required this.pageSize,
    required this.pageNumber,
    required this.hasMoreElements,
  });

  factory PaginationResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationResponseToJson(this);
}

/// Response para una sola venta
@JsonSerializable()
class VentaSingleResponse {
  @JsonKey(name: 'data')
  final VentaModel data;

  const VentaSingleResponse({required this.data});

  factory VentaSingleResponse.fromJson(Map<String, dynamic> json) =>
      _$VentaSingleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VentaSingleResponseToJson(this);
}
