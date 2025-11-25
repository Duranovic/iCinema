import 'package:injectable/injectable.dart';
import '../movie.dart';
import '../repositories/movies_repository.dart';

@lazySingleton
class AddMovieUseCase {
  final MoviesRepository _repository;

  AddMovieUseCase(this._repository);

  Future<Movie> call(Movie movie, {String? posterPath, String? mimeType}) {
    return _repository.addMovie(movie, posterPath: posterPath, mimeType: mimeType);
  }
}

