import '../entities/user.dart';

abstract class AuthRepository {
  Future<({String accessToken, String refreshToken, User user})> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<String> refreshToken(String refreshToken);

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  });

  Future<bool> validateToken();

  Future<User?> getCurrentUser();

  Future<bool> isLoggedIn();
}
