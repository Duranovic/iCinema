import 'package:injectable/injectable.dart';
import '../../domain/movie.dart';
import '../../domain/repositories/movies_repository.dart';
import '../movie_service.dart';

@LazySingleton(as: MoviesRepository)
class MoviesRepositoryImpl implements MoviesRepository {
  final MovieService _movieService;

  MoviesRepositoryImpl(this._movieService);

  @override
  Future<List<Movie>> getMovies() => _movieService.fetchMovies();

  @override
  Future<List<dynamic>> getGenres() => _movieService.fetchGenres();

  @override
  Future<List<dynamic>> getAgeRatings() => _movieService.fetchAgeRatings();

  @override
  Future<List<dynamic>> getDirectors() => _movieService.fetchDirectors();

  @override
  Future<List<dynamic>> getActors() => _movieService.fetchActors();

  @override
  Future<Movie> addMovie(Movie movie, {String? posterPath, String? mimeType}) =>
      _movieService.addMovie(movie, posterPath: posterPath, mimeType: mimeType);

  @override
  Future<Movie> updateMovie(Movie movie, {String? posterPath, String? mimeType}) =>
      _movieService.updateMovie(movie, posterPath: posterPath, mimeType: mimeType);

  @override
  Future<void> deleteMovie(String id) => _movieService.deleteMovie(id);

  @override
  Future<List<Map<String, dynamic>>> getCast(String movieId) =>
      _movieService.getCast(movieId);

  @override
  Future<void> addCast(String movieId, List<String> actorIds) =>
      _movieService.addCast(movieId, actorIds);

  @override
  Future<void> removeCast(String movieId, String actorId) =>
      _movieService.removeCast(movieId, actorId);
}

