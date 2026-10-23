import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int usuarioId;
  final int clienteId;
  final int rolId;
  final String nombre;
  final String email;
  final bool activo;
  final String nombreRol;
  final String prefijo;
  final String estadoPlan;
  final int diasActivos;
  final DateTime? createdAt;

  const User({
    required this.usuarioId,
    required this.clienteId,
    required this.rolId,
    required this.nombre,
    required this.email,
    required this.activo,
    required this.nombreRol,
    required this.prefijo,
    required this.estadoPlan,
    required this.diasActivos,
    this.createdAt,
  });

  bool get isSuperAdmin => rolId == 1;
  bool get isPlanActive => estadoPlan == 'activo';
  bool get isPlanExpired => estadoPlan == 'vencido';
  bool get isPlanBlocked => diasActivos < 0;

  @override
  List<Object?> get props => [
        usuarioId,
        clienteId,
        rolId,
        nombre,
        email,
        activo,
        nombreRol,
        prefijo,
        estadoPlan,
        diasActivos,
        createdAt,
      ];
}
