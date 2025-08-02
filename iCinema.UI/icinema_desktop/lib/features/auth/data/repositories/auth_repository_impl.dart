import 'package:icinema_desktop/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:icinema_desktop/features/auth/domain/entities/login_response.dart';
import 'package:icinema_desktop/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  AuthRepositoryImpl(this._remote);

  @override
  Future<LoginResponse> login({required String email, required String password}) async {
    final data = await _remote.login(email, password);
    return LoginResponse.fromJson(data);
  }
}