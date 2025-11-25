import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'package:icinema_shared/icinema_shared.dart';

// States
abstract class ProfileEditState {}

class ProfileEditInitial extends ProfileEditState {}

class ProfileEditLoading extends ProfileEditState {}

class ProfileEditSuccess extends ProfileEditState {
  final UserMeModel updatedUser;
  ProfileEditSuccess(this.updatedUser);
}

class ProfileEditError extends ProfileEditState {
  final String message;
  ProfileEditError(this.message);
}

// Cubit
class ProfileEditCubit extends Cubit<ProfileEditState> {
  final UpdateProfileUseCase _updateProfileUseCase;

  ProfileEditCubit(this._updateProfileUseCase) : super(ProfileEditInitial());

  Future<void> updateProfile({
    required String fullName,
    String? currentPassword,
    String? newPassword,
  }) async {
    if (fullName.trim().isEmpty) {
      emit(ProfileEditError('Ime i prezime ne može biti prazno.'));
      return;
    }

    // Validate password fields
    if (currentPassword != null && currentPassword.isNotEmpty) {
      if (newPassword == null || newPassword.isEmpty) {
        emit(ProfileEditError('Unesite novu lozinku.'));
        return;
      }
      if (newPassword.length < 6) {
        emit(ProfileEditError('Nova lozinka mora imati najmanje 6 karaktera.'));
        return;
      }
    }

    if (newPassword != null && newPassword.isNotEmpty) {
      if (currentPassword == null || currentPassword.isEmpty) {
        emit(ProfileEditError('Unesite trenutnu lozinku.'));
        return;
      }
    }

    emit(ProfileEditLoading());

    try {
      final updatedUser = await _updateProfileUseCase(
        fullName: fullName.trim(),
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      emit(ProfileEditSuccess(updatedUser));
    } catch (e) {
      emit(ProfileEditError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void reset() {
    emit(ProfileEditInitial());
  }
}
