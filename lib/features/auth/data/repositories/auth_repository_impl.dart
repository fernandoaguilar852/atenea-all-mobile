import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<({String accessToken, String refreshToken, User user})> login({
    required String email,
    required String password,
  }) async {
    final request = LoginRequest(email: email, password: password);
    final response = await _remoteDataSource.login(request);

    // Guardar datos localmente
    await _localDataSource.saveAuthData(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      user: response.user.toEntity(),
    );

    return (
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      user: response.user.toEntity(),
    );
  }

  @override
  Future<void> logout() async {
    // Obtener refreshToken antes de limpiar
    final refreshToken = await _localDataSource.getRefreshToken();

    // Llamar al backend para invalidar el token
    if (refreshToken != null) {
      await _remoteDataSource.logout(refreshToken);
    }

    // Limpiar datos locales
    await _localDataSource.clearAuthData();
  }

  @override
  Future<({String accessToken, String refreshToken})> refreshToken(
    String refreshToken,
  ) async {
    final tokens = await _remoteDataSource.refreshToken(refreshToken);

    return (
      accessToken: tokens['accessToken']!,
      refreshToken: tokens['refreshToken']!,
    );
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _remoteDataSource.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    await _remoteDataSource.changePassword(
      email: email,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<bool> validateToken() async {
    final token = await _localDataSource.getAccessToken();
    if (token == null) return false;
    return await _remoteDataSource.validateToken(token);
  }

  @override
  Future<User?> getCurrentUser() async {
    return await _localDataSource.getCurrentUser();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _localDataSource.hasAuthData();
  }
}
