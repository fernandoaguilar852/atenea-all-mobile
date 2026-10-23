import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<({String accessToken, String refreshToken, User user})> call({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty) {
      throw Exception('El email es requerido');
    }

    if (password.isEmpty) {
      throw Exception('La contraseña es requerida');
    }

    return await _repository.login(email: email, password: password);
  }
}
