import 'package:dio/dio.dart';
import 'package:icinema_shared/icinema_shared.dart';
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
      final response = await _dio.get(ApiEndpoints.movieById(movieId));
      
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

  /// Get current user's rating for a movie (requires auth)
  /// GET /movies/{id}/my-rating -> { "rating": number, "review": string? }
  Future<double?> getMyRating(String movieId) async {
    try {
      final resp = await _dio.get(ApiEndpoints.movieMyRating(movieId));
      if (resp.statusCode == 200) {
        if (resp.data == null) return null;
        if (resp.data is Map<String, dynamic>) {
          final data = resp.data as Map<String, dynamic>;
          // Support both keys: ratingValue and rating
          final raw = data.containsKey('ratingValue') ? data['ratingValue'] : data['rating'];
          if (raw == null) return null;
          double? val;
          if (raw is num) {
            val = raw.toDouble();
          } else {
            val = double.tryParse(raw.toString());
          }
          if (val == null) return null;
          // Clamp to 1..5 as server requires
          final clamped = val.round().clamp(1, 5).toDouble();
          return clamped;
        }
        // If API returns a bare number
        if (resp.data is num) {
          final clamped = (resp.data as num).toDouble().round().clamp(1, 5).toDouble();
          return clamped;
        }
        return null;
      }
      if (resp.statusCode == 404) return null; // no rating yet
      throw MoviesNetworkException('Failed to load my rating: ${resp.statusCode}');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      if (e.type == DioExceptionType.connectionTimeout ||
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

  /// Save current user's rating for a movie (and optional review)
  /// PUT /movies/{id}/rating body: { rating: number, review?: string }
  Future<void> saveMyRating({
    required String movieId,
    required double rating,
    String? review,
  }) async {
    try {
      // Backend expects integer 1..5. Clamp and round.
      final int intRating = rating.round().clamp(1, 5);
      await _dio.put(
        ApiEndpoints.movieRating(movieId),
        data: {
          'rating': intRating,
          // Some backends use RatingValue; send both for compatibility.
          'ratingValue': intRating,
          if (review != null) 'review': review,
        },
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
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

  /// Check if current user can rate the movie (requires auth)
  /// GET /movies/{id}/can-rate -> { allowed: bool } or { canRate: bool } or a bare bool
  Future<bool> canRate(String movieId) async {
    try {
      final resp = await _dio.get(ApiEndpoints.movieCanRate(movieId));
      if (resp.statusCode == 200) {
        final data = resp.data;
        if (data is bool) return data;
        if (data is Map<String, dynamic>) {
          final v = data['allowed'] ?? data['canRate'] ?? data['value'];
          if (v is bool) return v;
          if (v is num) return v != 0;
          if (v is String) return v.toLowerCase() == 'true';
        }
        return false;
      }
      if (resp.statusCode == 401) return false; // not authenticated
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return false;
      if (e.type == DioExceptionType.connectionTimeout ||
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
}
