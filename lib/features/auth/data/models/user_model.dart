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
  final String? sessionId;
  final int? iat; // Issued At - timestamp de emisión del token
  final int? exp; // Expiration - timestamp de expiración del token

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
    this.sessionId,
    this.iat,
    this.exp,
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
      sessionId: sessionId,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      tokenIssuedAt: iat != null
          ? DateTime.fromMillisecondsSinceEpoch(iat! * 1000)
          : null,
      tokenExpiresAt: exp != null
          ? DateTime.fromMillisecondsSinceEpoch(exp! * 1000)
          : null,
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
      sessionId: user.sessionId,
      createdAt: user.createdAt?.toIso8601String(),
      iat: user.tokenIssuedAt != null
          ? (user.tokenIssuedAt!.millisecondsSinceEpoch / 1000).round()
          : null,
      exp: user.tokenExpiresAt != null
          ? (user.tokenExpiresAt!.millisecondsSinceEpoch / 1000).round()
          : null,
    );
  }
}
