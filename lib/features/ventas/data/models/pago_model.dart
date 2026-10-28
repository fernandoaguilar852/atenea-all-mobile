import 'package:json_annotation/json_annotation.dart';

part 'pago_model.g.dart';

@JsonSerializable()
class PagoModel {
  @JsonKey(name: 'pagoId')
  final int pagoId;

  @JsonKey(name: 'metodo')
  final String metodo;

  @JsonKey(name: 'observacion')
  final String? observacion;

  @JsonKey(name: 'fecha')
  final String fecha;

  const PagoModel({
    required this.pagoId,
    required this.metodo,
    this.observacion,
    required this.fecha,
  });

  factory PagoModel.fromJson(Map<String, dynamic> json) =>
      _$PagoModelFromJson(json);

  Map<String, dynamic> toJson() => _$PagoModelToJson(this);
}

@JsonSerializable()
class PagoSingleResponse {
  @JsonKey(name: 'data')
  final PagoModel data;

  const PagoSingleResponse({required this.data});

  factory PagoSingleResponse.fromJson(Map<String, dynamic> json) =>
      _$PagoSingleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PagoSingleResponseToJson(this);
}
