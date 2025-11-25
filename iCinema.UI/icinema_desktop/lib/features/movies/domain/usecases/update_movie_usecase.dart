import 'package:injectable/injectable.dart';
import '../movie.dart';
import '../repositories/movies_repository.dart';

@lazySingleton
class UpdateMovieUseCase {
  final MoviesRepository _repository;

  UpdateMovieUseCase(this._repository);

  Future<Movie> call(Movie movie, {String? posterPath, String? mimeType}) {
    return _repository.updateMovie(movie, posterPath: posterPath, mimeType: mimeType);
  }
}

