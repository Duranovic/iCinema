import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';
import '../services/auth_service.dart';

// Allows injectable to register third-party types.
@module
abstract class NetworkModule {
  // Registers a lazy singleton Dio for entire app.
  @lazySingleton
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://localhost:7026', // Same as desktop app
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Configure certificate handling for development
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        // In development, accept all certificates for localhost
        // In production, implement proper certificate validation
        return host == 'localhost' || host == '127.0.0.1';
      };
      return client;
    };

    // Add logging interceptor for development
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) {
        // In production, you might want to use a proper logging framework
        print(object);
      },
    ));

    // Attach interceptor to inject Authorization header and handle 401
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final auth = GetIt.I<AuthService>();
        final token = auth.authState.token;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Unauthorized - clear session
          final auth = GetIt.I<AuthService>();
          await auth.logout();
        }
        handler.next(e);
      },
    ));

    return dio;
  }
}
