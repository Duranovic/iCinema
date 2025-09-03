
import 'package:icinema_desktop/features/movies/domain/movie.dart';

abstract class MoviesEvent {}

class LoadMovies extends MoviesEvent {}

class AddMovie extends MoviesEvent {
  final Movie movie;
  AddMovie(this.movie);
}

class UpdateMovie extends MoviesEvent {
  final Movie movie;
  UpdateMovie(this.movie);
}

class DeleteMovie extends MoviesEvent {
  final String? id;
  DeleteMovie(this.id);
}
