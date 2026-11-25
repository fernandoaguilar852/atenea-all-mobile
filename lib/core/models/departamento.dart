import 'package:json_annotation/json_annotation.dart';

part 'departamento.g.dart';

/// Departamento (catálogo global de ubicación)
@JsonSerializable()
class Departamento {
  final int departamentoId;
  final int? paisId;
  final String? codigoDane;
  final String nombre;
  @JsonKey(defaultValue: true)
  final bool activo;

  Departamento({
    required this.departamentoId,
    this.paisId,
    this.codigoDane,
    required this.nombre,
    this.activo = true,
  });

  factory Departamento.fromJson(Map<String, dynamic> json) =>
      _$DepartamentoFromJson(json);

  Map<String, dynamic> toJson() => _$DepartamentoToJson(this);
}
