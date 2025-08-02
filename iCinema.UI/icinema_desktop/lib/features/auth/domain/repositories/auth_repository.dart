import 'package:icinema_desktop/features/auth/domain/entities/login_response.dart';

abstract class AuthRepository {
  // Throws [AuthException] on failure
  Future<LoginResponse> login({required String email, required String password});
}