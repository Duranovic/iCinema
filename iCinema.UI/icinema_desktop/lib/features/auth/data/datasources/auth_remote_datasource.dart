import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<Map<String,dynamic>> login(String email, String password) async {
    final res = await _dio.post('/auth/login-admin', data: {
      'email': email,
      'password': password,
    });
    return res.data;
  }
}