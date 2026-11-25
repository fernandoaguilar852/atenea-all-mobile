import 'package:json_annotation/json_annotation.dart';

part 'cotizacion_model.g.dart';

/// Datos del consumidor asociado a la cotización
@JsonSerializable()
class ConsumidorModel {
  final String nombre;
  final String identificacion;
  final String? email;
  final String? telefono;

  const ConsumidorModel({
    required this.nombre,
    required this.identificacion,
    this.email,
    this.telefono,
  });

  factory ConsumidorModel.fromJson(Map<String, dynamic> json) =>
      _$ConsumidorModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConsumidorModelToJson(this);
}

/// Totales de la cotización
@JsonSerializable()
class TotalesModel {
  final double subtotalSinImpuestos;
  final double totalDescuentos;
  final double totalImpuestos;
  final double totalIva;
  final double totalInc;
  final double totalIca;
  final double total;

  const TotalesModel({
    required this.subtotalSinImpuestos,
    required this.totalDescuentos,
    required this.totalImpuestos,
    required this.totalIva,
    required this.totalInc,
    required this.totalIca,
    required this.total,
  });

  factory TotalesModel.fromJson(Map<String, dynamic> json) =>
      _$TotalesModelFromJson(json);

  Map<String, dynamic> toJson() => _$TotalesModelToJson(this);
}

/// DTO/Model para Cotización
/// Corresponde a la estructura JSON de la API
@JsonSerializable()
class CotizacionModel {
  final int cotizacionId;
  final int clienteId;
  final String numeroCotizacion;
  final ConsumidorModel consumidor;
  final String fechaCotizacion; // ISO date string
  final String fechaValidez; // ISO date string
  final int diasValidez;
  final bool estaVencida;
  final TotalesModel totales;
  final String createdAt;

  const CotizacionModel({
    required this.cotizacionId,
    required this.clienteId,
    required this.numeroCotizacion,
    required this.consumidor,
    required this.fechaCotizacion,
    required this.fechaValidez,
    required this.diasValidez,
    required this.estaVencida,
    required this.totales,
    required this.createdAt,
  });

  factory CotizacionModel.fromJson(Map<String, dynamic> json) =>
      _$CotizacionModelFromJson(json);

  Map<String, dynamic> toJson() => _$CotizacionModelToJson(this);
}

/// Data de cotizaciones
@JsonSerializable()
class CotizacionesData {
  final List<CotizacionModel> cotizaciones;

  const CotizacionesData({
    required this.cotizaciones,
  });

  factory CotizacionesData.fromJson(Map<String, dynamic> json) =>
      _$CotizacionesDataFromJson(json);

  Map<String, dynamic> toJson() => _$CotizacionesDataToJson(this);
}

/// Model de paginación
@JsonSerializable()
class PaginacionModel {
  final int totalElement;
  final int pageSize;
  final int pageNumber;
  final bool hasMoreElements;

  const PaginacionModel({
    required this.totalElement,
    required this.pageSize,
    required this.pageNumber,
    required this.hasMoreElements,
  });

  factory PaginacionModel.fromJson(Map<String, dynamic> json) =>
      _$PaginacionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaginacionModelToJson(this);
}

/// Respuesta de la API con data y paginación
@JsonSerializable()
class CotizacionesResponse {
  final CotizacionesData data;
  final PaginacionModel? pagination;

  const CotizacionesResponse({
    required this.data,
    this.pagination,
  });

  factory CotizacionesResponse.fromJson(Map<String, dynamic> json) =>
      _$CotizacionesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CotizacionesResponseToJson(this);
}
