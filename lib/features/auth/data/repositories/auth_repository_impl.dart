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
    // Llamar al backend para invalidar el token
    await _remoteDataSource.logout();

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
    required String code,
    required String newPassword,
  }) async {
    await _remoteDataSource.resetPassword(
      code: code,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _remoteDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<bool> validateToken() async {
    return await _remoteDataSource.validateToken();
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
