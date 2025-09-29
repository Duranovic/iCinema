
import 'package:icinema_desktop/features/movies/domain/movie.dart';

abstract class MoviesEvent {}

class LoadMovies extends MoviesEvent {}

class AddMovie extends MoviesEvent {
  final Movie movie;
  final String? posterPath;
  final String? mimeType;
  AddMovie(this.movie, {this.posterPath, this.mimeType});
}

class UpdateMovie extends MoviesEvent {
  final Movie movie;
  final String? posterPath;
  final String? mimeType;
  UpdateMovie(this.movie, {this.posterPath, this.mimeType});
}

class DeleteMovie extends MoviesEvent {
  final String? id;
  DeleteMovie(this.id);
}
