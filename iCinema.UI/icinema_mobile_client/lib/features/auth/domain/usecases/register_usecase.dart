import '../repositories/auth_repository.dart';

/// Use case for user registration
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  /// Execute registration with email, password, and optional full name
  /// Returns a tuple of (token, expiresAt)
  Future<(String token, DateTime? expiresAt)> call({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return await _repository.register(
      email: email,
      password: password,
      fullName: fullName,
    );
  }
}

