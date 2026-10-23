import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  // Auth Tokens
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: StorageKeys.accessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: StorageKeys.accessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: StorageKeys.refreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageKeys.refreshToken);
  }

  // User Data
  Future<void> saveUserId(String id) async {
    await _storage.write(key: StorageKeys.userId, value: id);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: StorageKeys.userId);
  }

  Future<void> saveClienteId(String id) async {
    await _storage.write(key: StorageKeys.clienteId, value: id);
  }

  Future<String?> getClienteId() async {
    return await _storage.read(key: StorageKeys.clienteId);
  }

  Future<void> saveUserData(Map<String, String> userData) async {
    await _storage.write(key: StorageKeys.nombre, value: userData['nombre']);
    await _storage.write(key: StorageKeys.email, value: userData['email']);
    await _storage.write(key: StorageKeys.rolId, value: userData['rolId']);
    await _storage.write(
        key: StorageKeys.nombreRol, value: userData['nombreRol']);
    await _storage.write(key: StorageKeys.prefijo, value: userData['prefijo']);
    await _storage.write(
        key: StorageKeys.estadoPlan, value: userData['estadoPlan']);
    await _storage.write(
        key: StorageKeys.diasActivos, value: userData['diasActivos']);
  }

  Future<Map<String, String?>> getUserData() async {
    return {
      'nombre': await _storage.read(key: StorageKeys.nombre),
      'email': await _storage.read(key: StorageKeys.email),
      'rolId': await _storage.read(key: StorageKeys.rolId),
      'nombreRol': await _storage.read(key: StorageKeys.nombreRol),
      'prefijo': await _storage.read(key: StorageKeys.prefijo),
      'estadoPlan': await _storage.read(key: StorageKeys.estadoPlan),
      'diasActivos': await _storage.read(key: StorageKeys.diasActivos),
    };
  }

  // Clear
  Future<void> clearAuthData() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
  }

  Future<void> clearUserData() async {
    await _storage.delete(key: StorageKeys.userId);
    await _storage.delete(key: StorageKeys.clienteId);
    await _storage.delete(key: StorageKeys.nombre);
    await _storage.delete(key: StorageKeys.email);
    await _storage.delete(key: StorageKeys.rolId);
    await _storage.delete(key: StorageKeys.nombreRol);
    await _storage.delete(key: StorageKeys.prefijo);
    await _storage.delete(key: StorageKeys.estadoPlan);
    await _storage.delete(key: StorageKeys.diasActivos);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Settings
  Future<void> saveThemeMode(String mode) async {
    await _storage.write(key: StorageKeys.themeMode, value: mode);
  }

  Future<String?> getThemeMode() async {
    return await _storage.read(key: StorageKeys.themeMode);
  }

  Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(
        key: StorageKeys.biometric, value: enabled.toString());
  }

  Future<bool> getBiometricEnabled() async {
    final value = await _storage.read(key: StorageKeys.biometric);
    return value == 'true';
  }
}
