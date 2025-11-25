import '../../data/models/movie_model.dart';
import '../repositories/movies_repository.dart';

/// Use case for getting movie by ID
class GetMovieByIdUseCase {
  final MoviesRepository _repository;

  GetMovieByIdUseCase(this._repository);

  /// Execute getting movie by ID
  Future<MovieModel> call(String movieId) async {
    return await _repository.getMovieById(movieId);
  }
}

/// Use case for getting multiple movies by IDs
class GetMoviesByIdsUseCase {
  final MoviesRepository _repository;

  GetMoviesByIdsUseCase(this._repository);

  /// Execute getting multiple movies
  Future<List<MovieModel>> call(List<String> movieIds) async {
    return await _repository.getMoviesByIds(movieIds);
  }
}

