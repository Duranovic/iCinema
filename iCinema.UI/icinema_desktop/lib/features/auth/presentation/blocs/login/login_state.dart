import 'package:equatable/equatable.dart';
import 'package:icinema_desktop/features/auth/domain/entities/login_response.dart';

// Base class for login state in the authentication flow.
abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];

  String friendlyError(String error) {
    // Add more parsing rules as needed!
    if (error.contains('SocketException') ||
        error.contains('connection error') ||
        error.contains('Connection failed')) {
      return 'Nije se moguće povezati na server. Provjerite vašu konekciju ili pokušajte ponovo.';
    }
    if (error.toLowerCase().contains('401') || error.toLowerCase().contains('unauthorized')) {
      return 'Email ili lozinka pogrešni.';
    }
    return 'Prijava neuspješna. Pokušajte ponovo.';
  }
}

/// Initial state before any action.
class LoginInitial extends LoginState {
  const LoginInitial();
}

/// State when login request is in progress.
class LoginLoading extends LoginState {
  const LoginLoading();
}

/// State when login succeeds, holding the authenticated [User].
class LoginSuccess extends LoginState {
  final LoginResponse loginResponse;

  const LoginSuccess(this.loginResponse);

  @override
  List<Object?> get props => [loginResponse];
}

/// State when login fails, holding an error message.
class LoginFailure extends LoginState {
  final String message;

  const LoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}
