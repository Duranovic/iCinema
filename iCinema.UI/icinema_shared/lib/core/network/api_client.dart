import 'package:dio/dio.dart';
import '../errors/network_exception.dart';

/// Base API client with common functionality
abstract class ApiClient {
  final Dio dio;

  ApiClient(this.dio);

  /// Handles DioException and converts to NetworkException
  T handleError<T>(DioException error) {
    if (error.response?.statusCode == 401) {
      throw const UnauthorizedException();
    }
    if (error.response?.statusCode == 404) {
      throw const NotFoundException();
    }
    if (error.response?.statusCode != null && error.response!.statusCode! >= 500) {
      throw ServerException(
        message: extractErrorMessage(error),
        statusCode: error.response?.statusCode,
        responseBody: error.response?.data?.toString(),
        originalError: error,
      );
    }
    if (error.response?.statusCode != null && error.response!.statusCode! >= 400) {
      throw ClientException(
        message: extractErrorMessage(error),
        statusCode: error.response?.statusCode,
        responseBody: error.response?.data?.toString(),
        originalError: error,
      );
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      throw ConnectionException(
        message: extractErrorMessage(error),
        statusCode: error.response?.statusCode,
        responseBody: error.response?.data?.toString(),
        originalError: error,
      );
    }
    throw NetworkException.fromDioError(error);
  }

  /// Extracts error message from response
  String extractErrorMessage(dynamic error) {
    if (error is NetworkException) {
      return error.message;
    }
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        return data['message'] as String? ??
            data['error'] as String? ??
            data['title'] as String? ??
            'An error occurred';
      }
      if (data is String && data.isNotEmpty) {
        return data;
      }
      return error.message ?? 'Network error occurred';
    }
    return error.toString();
  }
}

