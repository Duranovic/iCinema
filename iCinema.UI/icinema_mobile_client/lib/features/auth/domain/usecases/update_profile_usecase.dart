import 'package:icinema_shared/icinema_shared.dart';
import '../repositories/auth_repository.dart';

/// Use case for updating user profile
class UpdateProfileUseCase {
  final AuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  /// Execute profile update
  Future<UserMeModel> call({
    required String fullName,
    String? currentPassword,
    String? newPassword,
  }) async {
    return await _repository.updateProfile(
      fullName: fullName,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}

