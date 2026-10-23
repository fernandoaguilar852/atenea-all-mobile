import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user.dart';

class AuthLocalDataSource {
  final SecureStorageService _secureStorage;

  AuthLocalDataSource(this._secureStorage);

  Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required User user,
  }) async {
    await _secureStorage.saveAccessToken(accessToken);
    await _secureStorage.saveRefreshToken(refreshToken);
    await _secureStorage.saveUserId(user.usuarioId.toString());
    await _secureStorage.saveClienteId(user.clienteId.toString());
    await _secureStorage.saveUserData({
      'nombre': user.nombre,
      'email': user.email,
      'rolId': user.rolId.toString(),
      'nombreRol': user.nombreRol,
      'prefijo': user.prefijo,
      'estadoPlan': user.estadoPlan,
      'diasActivos': user.diasActivos.toString(),
    });
  }

  Future<User?> getCurrentUser() async {
    final userData = await _secureStorage.getUserData();

    if (userData['email'] == null) {
      return null;
    }

    final userId = await _secureStorage.getUserId();
    final clienteId = await _secureStorage.getClienteId();

    return User(
      usuarioId: int.tryParse(userId ?? '0') ?? 0,
      clienteId: int.tryParse(clienteId ?? '0') ?? 0,
      rolId: int.tryParse(userData['rolId'] ?? '0') ?? 0,
      nombre: userData['nombre'] ?? '',
      email: userData['email'] ?? '',
      activo: true,
      nombreRol: userData['nombreRol'] ?? '',
      prefijo: userData['prefijo'] ?? '',
      estadoPlan: userData['estadoPlan'] ?? '',
      diasActivos: int.tryParse(userData['diasActivos'] ?? '0') ?? 0,
    );
  }

  Future<void> clearAuthData() async {
    await _secureStorage.clearAuthData();
    await _secureStorage.clearUserData();
  }

  Future<bool> hasAuthData() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
