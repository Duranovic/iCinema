import '../../domain/movie.dart';

abstract class MoviesState {}

class MoviesInitial extends MoviesState {}

class MoviesLoading extends MoviesState {}

class MoviesLoaded extends MoviesState {
  final List<Movie> movies;
  final List<dynamic> genres;
  final List<dynamic> ageRatings; // [{code,label}]
  final List<dynamic> directors; // [{id, fullName}]
  final List<dynamic> actors; // [{id, fullName}]
  final String? successMessage;

  MoviesLoaded(
    this.movies,
    this.genres,
    this.ageRatings,
    this.directors,
    this.actors, {
    this.successMessage,
  });

  MoviesLoaded copyWith({
    List<Movie>? movies,
    List<dynamic>? genres,
    List<dynamic>? ageRatings,
    List<dynamic>? directors,
    List<dynamic>? actors,
    String? successMessage,
  }) {
    return MoviesLoaded(
      movies ?? this.movies,
      genres ?? this.genres,
      ageRatings ?? this.ageRatings,
      directors ?? this.directors,
      actors ?? this.actors,
      successMessage: successMessage,
    );
  }
}

class MoviesError extends MoviesState {
  final String message;
  MoviesError(this.message);
}
