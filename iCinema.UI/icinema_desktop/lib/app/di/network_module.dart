import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:icinema_desktop/app/services/auth_service.dart';
import 'package:injectable/injectable.dart';

// Allows injectable to register third-party types.
@module
abstract class NetworkModule {
  // Registers a lazy singleton Dio for entire app.
  @lazySingleton
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://localhost:7026',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );

    // Attach interceptor to inject Authorization header and handle 401
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final auth = GetIt.I<AuthService>();
        final token = auth.token;
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