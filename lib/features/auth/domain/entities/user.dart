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
  final String? sessionId;
  final DateTime? createdAt;
  final DateTime? tokenIssuedAt;
  final DateTime? tokenExpiresAt;

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
    this.sessionId,
    this.createdAt,
    this.tokenIssuedAt,
    this.tokenExpiresAt,
  });

  bool get isSuperAdmin => rolId == 1;
  bool get isAdmin => rolId == 2;
  bool get isPlanActive => estadoPlan == 'activo';
  bool get isPlanExpired => estadoPlan == 'vencido';
  bool get isPlanBlocked => diasActivos < 0;
  bool get isPlanNearExpiry => diasActivos > 0 && diasActivos <= 7;

  /// Verifica si el token ha expirado
  bool get isTokenExpired {
    if (tokenExpiresAt == null) return false;
    return DateTime.now().isAfter(tokenExpiresAt!);
  }

  /// Obtiene el tiempo restante antes de que expire el token
  Duration? get timeUntilTokenExpires {
    if (tokenExpiresAt == null) return null;
    return tokenExpiresAt!.difference(DateTime.now());
  }

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
        sessionId,
        createdAt,
        tokenIssuedAt,
        tokenExpiresAt,
      ];
}
