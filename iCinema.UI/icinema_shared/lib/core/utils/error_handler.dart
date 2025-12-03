import 'package:dio/dio.dart';
import '../errors/network_exception.dart';

/// Utility class for consistent error handling across the app
class ErrorHandler {
  /// Extracts a user-friendly error message from any exception
  static String getMessage(dynamic error) {
    if (error is NetworkException) {
      return _getNetworkErrorMessage(error);
    }
    
    if (error is DioException) {
      return _getDioErrorMessage(error);
    }
    
    if (error is Exception) {
      final message = error.toString();
      // Clean up common prefixes
      return message
          .replaceFirst('Exception: ', '')
          .replaceFirst('FormatException: ', '')
          .replaceFirst('StateError: ', '')
          .replaceFirst('DioException: ', '');
    }
    
    return error?.toString() ?? 'An unexpected error occurred';
  }

  static String _getDioErrorMessage(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;

    // 1. Try to extract backend message from response body
    if (data is Map<String, dynamic>) {
      if (data.containsKey('message') && data['message'] != null) return data['message'].toString();
      if (data.containsKey('error') && data['error'] != null) return data['error'].toString();
      if (data.containsKey('title') && data['title'] != null) return data['title'].toString();
    } else if (data != null) {
      // Handle string response or any other type that can be converted to string
      final dataStr = data.toString().trim();
      if (dataStr.isNotEmpty && !dataStr.startsWith('{') && !dataStr.startsWith('<') && !dataStr.startsWith('<!')) {
        return dataStr;
      }
    }

    // 2. Fallback to standard messages based on status code
    if (status != null) {
        if (status == 400) return 'Zahtjev odbijen (400).';
        if (status == 401) return 'Sesija je istekla. Molimo prijavite se ponovo.';
        if (status == 403) return 'Nemate dozvolu za ovu akciju.';
        if (status == 404) return 'Traženi resurs nije pronađen.';
        if (status == 409) return 'Došlo je do konflikta podataka.';
        if (status >= 500) return 'Greška na serveru. Pokušajte ponovo kasnije.';
    }
    
    // 3. Connection errors
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
       return 'Problem sa konekcijom. Provjerite internet.';
    }

    // 4. Fallback
    return 'Došlo je do mrežne greške.';
  }

  static String _getNetworkErrorMessage(NetworkException error) {
    // Check for specific exception types first
    if (error is UnauthorizedException) {
      return 'Session expired. Please log in again.';
    }
    
    if (error is NotFoundException) {
      return 'The requested resource was not found.';
    }
    
    if (error is ConnectionException) {
      return 'Unable to connect. Please check your internet connection.';
    }
    
    if (error is ServerException) {
      return 'Server error. Please try again later.';
    }
    
    // Check status codes
    final statusCode = error.statusCode;
    if (statusCode != null) {
      if (statusCode == 400) {
        return error.message.isNotEmpty ? error.message : 'Invalid request.';
      }
      if (statusCode == 401) {
        return 'Session expired. Please log in again.';
      }
      if (statusCode == 403) {
        return 'You do not have permission to perform this action.';
      }
      if (statusCode == 404) {
        return 'The requested resource was not found.';
      }
      if (statusCode == 409) {
        return error.message.isNotEmpty ? error.message : 'Conflict with existing data.';
      }
      if (statusCode >= 500) {
        return 'Server error. Please try again later.';
      }
    }
    
    // Return the error message if available
    if (error.message.isNotEmpty) {
      return error.message;
    }
    
    return 'A network error occurred. Please try again.';
  }

  /// Wraps an async operation with standardized error handling
  /// Returns a tuple of (result, errorMessage)
  static Future<(T?, String?)> tryAsync<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return (result, null);
    } catch (e) {
      return (null, getMessage(e));
    }
  }

  /// Checks if the error is an authentication error (401)
  static bool isAuthError(dynamic error) {
    if (error is UnauthorizedException) return true;
    if (error is NetworkException && error.statusCode == 401) return true;
    return false;
  }

  /// Checks if the error is a connection error
  static bool isConnectionError(dynamic error) {
    if (error is ConnectionException) return true;
    // Check for common connection error patterns
    final message = error.toString().toLowerCase();
    return message.contains('socketexception') ||
           message.contains('connection') ||
           message.contains('timeout') ||
           message.contains('handshake');
  }
}



