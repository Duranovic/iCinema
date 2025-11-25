import '../repositories/auth_repository.dart';

/// Use case for user login
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  /// Execute login with email and password
  /// Returns a tuple of (token, expiresAt)
  Future<(String token, DateTime? expiresAt)> call({
    required String email,
    required String password,
  }) async {
    return await _repository.login(email: email, password: password);
  }
}

