import '../../domain/repositories/movies_repository.dart';
import '../datasources/movies_api_service.dart';
import '../models/movie_model.dart';

/// Implementation of MoviesRepository
class MoviesRepositoryImpl implements MoviesRepository {
  final MoviesApiService _moviesApiService;

  MoviesRepositoryImpl(this._moviesApiService);

  @override
  Future<MovieModel> getMovieById(String movieId) async {
    return await _moviesApiService.getMovieById(movieId);
  }

  @override
  Future<List<MovieModel>> getMoviesByIds(List<String> movieIds) async {
    return await _moviesApiService.getMoviesByIds(movieIds);
  }

  @override
  Future<double?> getMyRating(String movieId) async {
    return await _moviesApiService.getMyRating(movieId);
  }

  @override
  Future<void> submitRating(String movieId, double rating, String? review) async {
    return await _moviesApiService.saveMyRating(movieId: movieId, rating: rating, review: review);
  }

  @override
  Future<void> deleteRating(String movieId) async {
    // Note: If delete endpoint exists, implement it here
    throw UnimplementedError('Delete rating not yet implemented');
  }

  @override
  Future<bool> canRate(String movieId) async {
    return await _moviesApiService.canRate(movieId);
  }
}

