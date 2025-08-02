import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/login_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _login;
  LoginBloc(this._login) : super(const LoginInitial()) {
    on<LoginSubmitted>((e, emit) async {
      if (!e.formKey.currentState!.validate()) return;
      emit(const LoginLoading());
      try {
        final user = await _login(e.email, e.password);
        emit(LoginSuccess(user));
      } catch (err) {
        emit(LoginFailure(err.toString()));
      }
    });
  }
}