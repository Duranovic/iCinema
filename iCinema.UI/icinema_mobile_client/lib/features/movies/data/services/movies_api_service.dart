import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/movie_model.dart';

// Custom exceptions for movie API
abstract class MoviesException implements Exception {
  final String message;
  const MoviesException(this.message);
}

class MovieNotFoundException extends MoviesException {
  const MovieNotFoundException(super.message);
}

class MoviesNetworkException extends MoviesException {
  const MoviesNetworkException(super.message);
}

class MoviesUnknownException extends MoviesException {
  const MoviesUnknownException(super.message);
}

@injectable
class MoviesApiService {
  final Dio _dio;

  const MoviesApiService(this._dio);

  /// Get movie details by ID
  /// GET /movies/{id}
  Future<MovieModel> getMovieById(String movieId) async {
    try {
      final response = await _dio.get('/movies/$movieId');
      
      if (response.statusCode == 200) {
        return MovieModel.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw const MovieNotFoundException('Movie not found');
      } else {
        throw MoviesNetworkException('Failed to fetch movie: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const MovieNotFoundException('Movie not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        throw const MoviesNetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const MoviesNetworkException('No internet connection');
      } else {
        throw MoviesNetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw MoviesUnknownException('Unknown error occurred: $e');
    }
  }

  /// Get multiple movies by IDs (batch request)
  /// This could be useful for fetching multiple movie details at once
  Future<List<MovieModel>> getMoviesByIds(List<String> movieIds) async {
    final List<MovieModel> movies = [];
    
    // Execute requests concurrently for better performance
    final futures = movieIds.map((id) => getMovieById(id));
    
    try {
      final results = await Future.wait(futures);
      movies.addAll(results);
    } catch (e) {
      // If any request fails, we could handle it gracefully
      // For now, we'll let the exception bubble up
      rethrow;
    }
    
    return movies;
  }
}
