import 'package:injectable/injectable.dart';
import '../repositories/movies_repository.dart';

@lazySingleton
class DeleteMovieUseCase {
  final MoviesRepository _repository;

  DeleteMovieUseCase(this._repository);

  Future<void> call(String id) {
    return _repository.deleteMovie(id);
  }
}

