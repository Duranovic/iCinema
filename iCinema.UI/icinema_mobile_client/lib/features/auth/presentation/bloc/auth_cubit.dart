import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icinema_shared/icinema_shared.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/get_me_usecase.dart';
import '../../../../app/services/auth_service.dart' as auth_svc;
import '../../../../app/services/signalr_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final GetMeUseCase _getMeUseCase;
  final auth_svc.AuthService _authService;
  final SignalRService? _signalRService;

  AuthCubit(
    this._loginUseCase,
    this._registerUseCase,
    this._getMeUseCase,
    this._authService, [
    this._signalRService,
  ]) : super(AuthState.unauthenticated());

  Future<void> init() async {
    await _authService.init();
    final token = _authService.authState.token;
    if (token != null && token.isNotEmpty) {
      try {
        final me = await _getMeUseCase();
        emit(AuthState.authenticated(me, token));
        // Connect to SignalR for real-time notifications
        _signalRService?.connect();
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
      final (token, expiresAt) = await _loginUseCase(
        email: email,
        password: password,
      );
      await _authService.setSession(token: token, email: email, expiresAt: expiresAt);
      final me = await _getMeUseCase();
      emit(AuthState.authenticated(me, token));
      // Connect to SignalR for real-time notifications
      _signalRService?.connect();
    } catch (e) {
      emit(AuthState.error(ErrorHandler.getMessage(e)));
    }
  }

  Future<void> logout() async {
    await _signalRService?.disconnect();
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
      final (token, expiresAt) = await _registerUseCase(
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
      final me = await _getMeUseCase();
      emit(AuthState.authenticated(me, token));
      // Connect to SignalR for real-time notifications
      _signalRService?.connect();
    } catch (e) {
      emit(AuthState.error(ErrorHandler.getMessage(e)));
    }
  }
}
