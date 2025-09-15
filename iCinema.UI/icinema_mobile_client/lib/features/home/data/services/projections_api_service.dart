import 'package:dio/dio.dart';
import '../models/projection_model.dart';

class ProjectionsApiService {
  final Dio _dio;

  ProjectionsApiService(this._dio);

  /// Fetch projections with optional start and end date filters
  Future<ProjectionsResponse> getProjections({
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy,
    bool? descending,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      if (startDate != null) {
        queryParams['StartDate'] = startDate.toIso8601String();
      }
      
      if (endDate != null) {
        queryParams['EndDate'] = endDate.toIso8601String();
      }
      
      if (sortBy != null) {
        queryParams['SortBy'] = sortBy;
      }
      
      if (descending != null) {
        queryParams['Descending'] = descending;
      }

      final response = await _dio.get(
        '/projections',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return ProjectionsResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch projections: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ProjectionsNotFoundException('No projections found');
      } else if (e.response?.statusCode == 500) {
        throw ProjectionsServerException('Server error occurred');
      } else {
        throw ProjectionsNetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ProjectionsUnknownException('Unknown error occurred: $e');
    }
  }

  /// Get projections for today only
  Future<ProjectionsResponse> getTodayProjections() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    return getProjections(
      startDate: startOfDay, 
      endDate: endOfDay,
      sortBy: 'StartDate',
      descending: true, // Ascending order - earliest times first
    );
  }

  /// Get projections for upcoming days (from tomorrow onwards)
  Future<ProjectionsResponse> getUpcomingProjections() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final startOfTomorrow = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    return getProjections(
      startDate: startOfTomorrow,
      sortBy: 'StartDate',
      descending: false, // Ascending order - earliest dates first
    );
  }

  /// Get projections for a specific date range
  Future<ProjectionsResponse> getProjectionsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Now we can use both startDate and endDate in the API call
    return getProjections(startDate: startDate, endDate: endDate);
  }
}

// Custom exceptions for better error handling
abstract class ProjectionsException implements Exception {
  final String message;
  const ProjectionsException(this.message);
}

class ProjectionsNotFoundException extends ProjectionsException {
  const ProjectionsNotFoundException(super.message);
}

class ProjectionsServerException extends ProjectionsException {
  const ProjectionsServerException(super.message);
}

class ProjectionsNetworkException extends ProjectionsException {
  const ProjectionsNetworkException(super.message);
}

class ProjectionsUnknownException extends ProjectionsException {
  const ProjectionsUnknownException(super.message);
}
