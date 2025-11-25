import 'package:injectable/injectable.dart';
import '../movie.dart';
import '../repositories/movies_repository.dart';

@lazySingleton
class LoadMoviesUseCase {
  final MoviesRepository _repository;

  LoadMoviesUseCase(this._repository);

  Future<MoviesData> call() async {
    final results = await Future.wait([
      _repository.getMovies(),
      _repository.getGenres(),
      _repository.getAgeRatings(),
      _repository.getDirectors(),
      _repository.getActors(),
    ]);

    return MoviesData(
      movies: results[0] as List<Movie>,
      genres: results[1] as List<dynamic>,
      ageRatings: results[2] as List<dynamic>,
      directors: results[3] as List<dynamic>,
      actors: results[4] as List<dynamic>,
    );
  }
}

class MoviesData {
  final List<Movie> movies;
  final List<dynamic> genres;
  final List<dynamic> ageRatings;
  final List<dynamic> directors;
  final List<dynamic> actors;

  MoviesData({
    required this.movies,
    required this.genres,
    required this.ageRatings,
    required this.directors,
    required this.actors,
  });
}

