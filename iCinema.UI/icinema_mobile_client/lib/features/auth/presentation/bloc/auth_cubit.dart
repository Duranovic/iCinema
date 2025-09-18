import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/auth_api_service.dart';
import '../../../../app/services/auth_service.dart' as auth_svc;
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthApiService _api;
  final auth_svc.AuthService _authService;

  AuthCubit(this._api, this._authService) : super(AuthState.unauthenticated());

  Future<void> init() async {
    await _authService.init();
    final token = _authService.authState.token;
    if (token != null && token.isNotEmpty) {
      try {
        final me = await _api.getMe();
        emit(AuthState.authenticated(me, token));
      } catch (_) {
        emit(AuthState.unauthenticated());
      }
    } else {
      emit(AuthState.unauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthState.authenticating());
    try {
      final (token, expiresAt) = await _api.login(email: email, password: password);
      await _authService.setSession(token: token, email: email, expiresAt: expiresAt);
      final me = await _api.getMe();
      emit(AuthState.authenticated(me, token));
    } catch (e) {
      emit(AuthState.error(e.toString().replaceFirst('Exception: ', '')));
      emit(AuthState.unauthenticated());
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    emit(AuthState.unauthenticated());
  }

  Future<void> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    emit(AuthState.authenticating());
    try {
      final (token, expiresAt) = await _api.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      await _authService.setSession(
        token: token,
        email: email,
        expiresAt: expiresAt,
        fullName: fullName,
      );
      final me = await _api.getMe();
      emit(AuthState.authenticated(me, token));
    } catch (e) {
      emit(AuthState.error(e.toString().replaceFirst('Exception: ', '')));
      emit(AuthState.unauthenticated());
    }
  }
}
