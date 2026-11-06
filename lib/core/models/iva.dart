import 'package:json_annotation/json_annotation.dart';

part 'iva.g.dart';

@JsonSerializable()
class Iva {
  final int ivaId;
  final String valor;
  final String descripcion;
  final bool activo;

  Iva({
    required this.ivaId,
    required this.valor,
    required this.descripcion,
    required this.activo,
  });

  factory Iva.fromJson(Map<String, dynamic> json) => _$IvaFromJson(json);

  Map<String, dynamic> toJson() => _$IvaToJson(this);

  String get displayName => descripcion;
}

@JsonSerializable()
class IvaData {
  final List<Iva> ivas;

  IvaData({required this.ivas});

  factory IvaData.fromJson(Map<String, dynamic> json) => _$IvaDataFromJson(json);

  Map<String, dynamic> toJson() => _$IvaDataToJson(this);
}

@JsonSerializable()
class IvaResponse {
  final IvaData data;

  IvaResponse({required this.data});

  factory IvaResponse.fromJson(Map<String, dynamic> json) => _$IvaResponseFromJson(json);

  Map<String, dynamic> toJson() => _$IvaResponseToJson(this);
}
