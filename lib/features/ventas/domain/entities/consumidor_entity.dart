import 'package:equatable/equatable.dart';

/// Entidad de dominio para Consumidor
class ConsumidorEntity extends Equatable {
  final int consumidorId;
  final String nombreRazonSocial;
  final String numeroIdentificacion;
  final String tipoIdentificacion;
  final String? direccion;
  final String? telefono;
  final String? email;

  const ConsumidorEntity({
    required this.consumidorId,
    required this.nombreRazonSocial,
    required this.numeroIdentificacion,
    required this.tipoIdentificacion,
    this.direccion,
    this.telefono,
    this.email,
  });

  @override
  List<Object?> get props => [
        consumidorId,
        nombreRazonSocial,
        numeroIdentificacion,
        tipoIdentificacion,
        direccion,
        telefono,
        email,
      ];
}
