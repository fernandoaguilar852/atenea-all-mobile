import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int usuarioId;
  final int clienteId;
  final int rolId;
  final String nombre;
  final String email;
  final bool activo;
  final String? createdAt;
  final String nombreRol;
  final String prefijo;
  final String estadoPlan;
  final int diasActivos;

  UserModel({
    required this.usuarioId,
    required this.clienteId,
    required this.rolId,
    required this.nombre,
    required this.email,
    required this.activo,
    this.createdAt,
    required this.nombreRol,
    required this.prefijo,
    required this.estadoPlan,
    required this.diasActivos,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toEntity() {
    return User(
      usuarioId: usuarioId,
      clienteId: clienteId,
      rolId: rolId,
      nombre: nombre,
      email: email,
      activo: activo,
      nombreRol: nombreRol,
      prefijo: prefijo,
      estadoPlan: estadoPlan,
      diasActivos: diasActivos,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      usuarioId: user.usuarioId,
      clienteId: user.clienteId,
      rolId: user.rolId,
      nombre: user.nombre,
      email: user.email,
      activo: user.activo,
      nombreRol: user.nombreRol,
      prefijo: user.prefijo,
      estadoPlan: user.estadoPlan,
      diasActivos: user.diasActivos,
      createdAt: user.createdAt?.toIso8601String(),
    );
  }
}
