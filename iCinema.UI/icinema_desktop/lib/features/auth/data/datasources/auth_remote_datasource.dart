import 'package:dio/dio.dart';
import 'package:icinema_shared/icinema_shared.dart';
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
    final res = await _dio.post(ApiEndpoints.loginAdmin, data: {
      'email': email,
      'password': password,
    });
    
    // Handle response data - ensure it's a Map
    if (res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    } else if (res.data is String) {
      // If response is a string, try to parse it as JSON
      throw Exception('Unexpected response format: ${res.data}');
    } else {
      throw Exception('Invalid response type: ${res.data.runtimeType}');
    }
  }
}