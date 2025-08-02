import 'package:icinema_desktop/features/auth/domain/entities/login_response.dart';
import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

@injectable
class LoginUseCase {
  final AuthRepository _repo;
  LoginUseCase(this._repo);

  Future<LoginResponse> call(String email, String password) {
    return _repo.login(email: email, password: password);
  }
}