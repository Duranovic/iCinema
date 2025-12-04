import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:icinema_desktop/app/services/auth_service.dart';
import 'package:injectable/injectable.dart';

// Allows injectable to register third-party types.
@module
abstract class NetworkModule {
  // Registers a lazy singleton Dio for entire app.
  @lazySingleton
  Dio get dio {
    // Get API URL from environment variable or use default
    // Can be set via: flutter run --dart-define=API_BASE_URL=https://localhost:7026
    // Or via: export API_BASE_URL=https://localhost:7026 (macOS/Linux) or set API_BASE_URL=https://localhost:7026 (Windows)
    // Default to HTTPS to avoid redirect issues
    final apiBaseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://localhost:7026',
    );
    
    final dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        followRedirects: true,
        maxRedirects: 5,
      ),
    );

    // Configure HTTP adapter to handle redirects and SSL
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      // In debug mode, allow self-signed certificates
      if (kDebugMode) {
        client.badCertificateCallback = (cert, host, port) => true;
      }
      return client;
    };

    // Add logging interceptor for development only (not in release builds)
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print(object),
      ));
    }

    // Attach interceptor to inject Authorization header and handle errors (401, 400)
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
        // Log connection errors for debugging
        if (kDebugMode && e.type == DioExceptionType.connectionError) {
          print('❌ Connection error to API at: ${e.requestOptions.baseUrl}${e.requestOptions.path}');
          print('   Error: ${e.message}');
          print('   Make sure the API is running and accessible at: $apiBaseUrl');
        }
        
        final status = e.response?.statusCode;
        if (status == 401) {
          // Unauthorized - clear session
          final auth = GetIt.I<AuthService>();
          await auth.logout();
          handler.next(e);
          return;
        }

        // Normalize business rule violations (HTTP 400) to provide a user-friendly message globally
        if (status == 400) {
          String message = 'Zahtjev odbijen (400).';
          final data = e.response?.data;
          if (data is Map<String, dynamic>) {
            message = data['message']?.toString() ?? data['error']?.toString() ?? message;
          } else if (data is String) {
            message = data;
          }
          final normalized = DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            type: e.type,
            error: e.error,
            stackTrace: e.stackTrace,
            message: message,
          );
          handler.next(normalized);
          return;
        }

        handler.next(e);
      },
    ));

    return dio;
  }
}