import 'package:dio/dio.dart';
import '../../errors/network_exception.dart';

/// Callback type for handling logout on 401
typedef LogoutHandler = Future<void> Function();

/// Interceptor for handling errors globally
class ErrorInterceptor extends Interceptor {
  final LogoutHandler? onUnauthorized;

  ErrorInterceptor({this.onUnauthorized});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized
    if (err.response?.statusCode == 401 && onUnauthorized != null) {
      await onUnauthorized!();
    }

    // Normalize business rule violations (HTTP 400) to provide user-friendly message
    if (err.response?.statusCode == 400) {
      String message = 'Request rejected (400).';
      final data = err.response?.data;
      if (data is Map<String, dynamic>) {
        message = data['message']?.toString() ??
            data['error']?.toString() ??
            data['title']?.toString() ??
            message;
      } else if (data is String) {
        message = data;
      }
      
      final normalized = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: err.error,
        stackTrace: err.stackTrace,
        message: message,
      );
      handler.next(normalized);
      return;
    }

    handler.next(err);
  }
}

