import 'package:json_annotation/json_annotation.dart';

part 'consumidor.g.dart';

@JsonSerializable()
class Consumidor {
  final int consumidorId;
  final int clienteId;
  final String tipoIdentificacion;
  final String numeroIdentificacion;
  final String? digitoVerificacion;
  final String nombreRazonSocial;
  final String? direccion;
  final String? email;
  final String? telefono;
  final int? ciudadId;
  final bool activo;
  final String creadoEn;

  Consumidor({
    required this.consumidorId,
    required this.clienteId,
    required this.tipoIdentificacion,
    required this.numeroIdentificacion,
    this.digitoVerificacion,
    required this.nombreRazonSocial,
    this.direccion,
    this.email,
    this.telefono,
    this.ciudadId,
    required this.activo,
    required this.creadoEn,
  });

  factory Consumidor.fromJson(Map<String, dynamic> json) =>
      _$ConsumidorFromJson(json);

  Map<String, dynamic> toJson() => _$ConsumidorToJson(this);

  String get displayName => '$consumidorId - $nombreRazonSocial';
}

@JsonSerializable()
class ConsumidorPagination {
  final int totalElement;
  final int pageSize;
  final int pageNumber;
  final bool hasMoreElements;

  ConsumidorPagination({
    required this.totalElement,
    required this.pageSize,
    required this.pageNumber,
    required this.hasMoreElements,
  });

  factory ConsumidorPagination.fromJson(Map<String, dynamic> json) =>
      _$ConsumidorPaginationFromJson(json);

  Map<String, dynamic> toJson() => _$ConsumidorPaginationToJson(this);
}

@JsonSerializable()
class ConsumidorResponse {
  final List<Consumidor> data;
  final ConsumidorPagination? pagination;

  ConsumidorResponse({
    required this.data,
    this.pagination,
  });

  factory ConsumidorResponse.fromJson(Map<String, dynamic> json) =>
      _$ConsumidorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ConsumidorResponseToJson(this);
}
