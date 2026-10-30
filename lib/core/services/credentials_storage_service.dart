import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class CredentialsStorageService {
  static const String _keyEmail = 'saved_email';
  static const String _keyPassword = 'saved_password';
  static const String _keyRememberMe = 'remember_me';

  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;

  CredentialsStorageService()
      : _secureStorage = const FlutterSecureStorage(),
        _localAuth = LocalAuthentication();

  /// Verifica si el dispositivo tiene biometría disponible
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Autentica con biometría (Face ID o huella)
  Future<bool> authenticateWithBiometrics() async {
    try {
      final hasBiometrics = await isBiometricAvailable();
      if (!hasBiometrics) return true; // Si no tiene biometría, permitir acceso

      return await _localAuth.authenticate(
        localizedReason: 'Verifica tu identidad para acceder',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  /// Guarda las credenciales de forma segura
  Future<void> saveCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      if (rememberMe) {
        await _secureStorage.write(key: _keyEmail, value: email);
        await _secureStorage.write(key: _keyPassword, value: password);
        await _secureStorage.write(key: _keyRememberMe, value: 'true');
      } else {
        await clearCredentials();
      }
    } catch (e) {
      throw Exception('Error al guardar credenciales: $e');
    }
  }

  /// Obtiene las credenciales guardadas (requiere biometría si está disponible)
  Future<SavedCredentials?> getCredentials() async {
    try {
      final rememberMe = await _secureStorage.read(key: _keyRememberMe);
      if (rememberMe != 'true') return null;

      // Verificar biometría si está disponible
      final hasBiometrics = await isBiometricAvailable();
      if (hasBiometrics) {
        final authenticated = await authenticateWithBiometrics();
        if (!authenticated) return null; // Falló la autenticación biométrica
      }

      final email = await _secureStorage.read(key: _keyEmail);
      final password = await _secureStorage.read(key: _keyPassword);

      if (email != null && password != null) {
        return SavedCredentials(email: email, password: password);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Verifica si hay credenciales guardadas (sin autenticar)
  Future<bool> hasCredentials() async {
    try {
      final rememberMe = await _secureStorage.read(key: _keyRememberMe);
      return rememberMe == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Borra las credenciales guardadas
  Future<void> clearCredentials() async {
    try {
      await _secureStorage.delete(key: _keyEmail);
      await _secureStorage.delete(key: _keyPassword);
      await _secureStorage.delete(key: _keyRememberMe);
    } catch (e) {
      throw Exception('Error al borrar credenciales: $e');
    }
  }
}

/// Modelo para credenciales guardadas
class SavedCredentials {
  final String email;
  final String password;

  SavedCredentials({
    required this.email,
    required this.password,
  });
}
