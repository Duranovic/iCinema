import 'app_exception.dart';

/// Exception for network-related errors
class NetworkException extends AppException {
  final int? statusCode;
  final String? responseBody;

  const NetworkException({
    required super.message,
    this.statusCode,
    this.responseBody,
    super.code,
    super.originalError,
  });

  /// Creates a NetworkException from a DioException
  static NetworkException fromDioError(dynamic error) {
    if (error is NetworkException) {
      return error;
    }

    // Try to extract status code and message from DioException
    final statusCode = _extractStatusCode(error);
    final message = _extractMessage(error) ?? 'Network error occurred';
    final responseBody = _extractResponseBody(error);

    return NetworkException(
      message: message,
      statusCode: statusCode,
      responseBody: responseBody,
      originalError: error,
    );
  }

  static int? _extractStatusCode(dynamic error) {
    try {
      return error?.response?.statusCode as int?;
    } catch (_) {
      return null;
    }
  }

  static String? _extractMessage(dynamic error) {
    try {
      // Try to get message from response data
      final data = error?.response?.data;
      if (data is Map) {
        return data['message'] as String? ?? 
               data['error'] as String? ?? 
               data['title'] as String?;
      }
      if (data is String && data.isNotEmpty) {
        return data;
      }
      // Fallback to error message
      return error?.message?.toString() ?? error?.toString();
    } catch (_) {
      return null;
    }
  }

  static String? _extractResponseBody(dynamic error) {
    try {
      final data = error?.response?.data;
      if (data is String) {
        return data;
      }
      if (data is Map) {
        return data.toString();
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

/// Exception for connection errors (no internet, timeout, etc.)
class ConnectionException extends NetworkException {
  const ConnectionException({
    required super.message,
    super.statusCode,
    super.responseBody,
    super.code,
    super.originalError,
  });
}

/// Exception for server errors (5xx)
class ServerException extends NetworkException {
  const ServerException({
    required super.message,
    super.statusCode,
    super.responseBody,
    super.code,
    super.originalError,
  });
}

/// Exception for client errors (4xx)
class ClientException extends NetworkException {
  const ClientException({
    required super.message,
    super.statusCode,
    super.responseBody,
    super.code,
    super.originalError,
  });
}

/// Exception for unauthorized errors (401)
class UnauthorizedException extends ClientException {
  const UnauthorizedException({
    super.message = 'Unauthorized access',
    super.statusCode = 401,
    super.responseBody,
    super.code,
    super.originalError,
  });
}

/// Exception for not found errors (404)
class NotFoundException extends ClientException {
  const NotFoundException({
    super.message = 'Resource not found',
    super.statusCode = 404,
    super.responseBody,
    super.code,
    super.originalError,
  });
}

