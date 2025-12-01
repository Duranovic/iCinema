import 'package:icinema_shared/icinema_shared.dart';
import '../repositories/auth_repository.dart';

/// Use case for getting current authenticated user
class GetMeUseCase {
  final AuthRepository _repository;

  GetMeUseCase(this._repository);

  /// Execute getting current user information
  Future<UserMeModel> call() async {
    return await _repository.getMe();
  }
}



