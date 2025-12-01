import '../movie.dart';

abstract class MoviesRepository {
  Future<List<Movie>> getMovies();
  Future<List<dynamic>> getGenres();
  Future<List<dynamic>> getAgeRatings();
  Future<List<dynamic>> getDirectors();
  Future<List<dynamic>> getActors();
  Future<Movie> addMovie(Movie movie, {String? posterPath, String? mimeType});
  Future<Movie> updateMovie(Movie movie, {String? posterPath, String? mimeType});
  Future<void> deleteMovie(String id);
  Future<List<Map<String, dynamic>>> getCast(String movieId);
  Future<void> addCast(String movieId, List<String> actorIds);
  Future<void> removeCast(String movieId, String actorId);
}



