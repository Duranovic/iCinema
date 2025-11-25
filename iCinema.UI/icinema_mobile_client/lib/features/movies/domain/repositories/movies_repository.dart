import '../../data/models/movie_model.dart';
import '../../data/models/movie_score_dto.dart';
import '../../../home/data/models/projection_model.dart';

/// Repository interface for movies feature operations
abstract class MoviesRepository {
  /// Get movie details by ID
  Future<MovieModel> getMovieById(String movieId);

  /// Get multiple movies by IDs
  Future<List<MovieModel>> getMoviesByIds(List<String> movieIds);

  /// Get current user's rating for a movie
  Future<double?> getMyRating(String movieId);

  /// Submit or update rating for a movie
  Future<void> submitRating(String movieId, double rating, String? review);

  /// Delete user's rating for a movie
  Future<void> deleteRating(String movieId);

  /// Check if user can rate the movie
  Future<bool> canRate(String movieId);
}

/// Repository interface for movie search operations
abstract class SearchRepository {
  /// Search movies with filters
  Future<SearchResult> searchMovies({
    required String search,
    int page = 1,
    int pageSize = 20,
    String? genreId,
    String? cinemaId,
    String? cityId,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? sortBy,
    bool descending = false,
  });
}

/// Repository interface for recommendations
abstract class RecommendationsRepository {
  /// Get similar movies
  Future<List<MovieScoreDto>> getSimilar({required String movieId, int top = 10});

  /// Get user's personalized recommendations
  Future<List<MovieScoreDto>> getMyRecommendations();
}

/// Search result model
class SearchResult {
  final List<MovieModel> items;
  final int total;
  final int page;
  final int pageSize;

  const SearchResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });
}

