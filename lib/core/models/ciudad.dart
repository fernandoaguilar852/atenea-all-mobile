import 'package:json_annotation/json_annotation.dart';

part 'ciudad.g.dart';

/// Ciudad (catálogo global de ubicación)
@JsonSerializable()
class Ciudad {
  final int ciudadId;
  final int departamentoId;
  final String? codigoDane;
  final String nombre;
  @JsonKey(defaultValue: true)
  final bool activo;

  Ciudad({
    required this.ciudadId,
    required this.departamentoId,
    this.codigoDane,
    required this.nombre,
    this.activo = true,
  });

  factory Ciudad.fromJson(Map<String, dynamic> json) => _$CiudadFromJson(json);

  Map<String, dynamic> toJson() => _$CiudadToJson(this);
}
