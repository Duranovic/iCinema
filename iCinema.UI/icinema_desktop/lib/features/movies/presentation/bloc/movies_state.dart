import '../../domain/movie.dart';

abstract class MoviesState {}

class MoviesInitial extends MoviesState {}

class MoviesLoading extends MoviesState {}

class MoviesLoaded extends MoviesState {
  final List<Movie> movies;
  final List<dynamic> genres;
  final List<dynamic> ageRatings; // [{code,label}]
  MoviesLoaded(this.movies, this.genres, this.ageRatings);
}

class MoviesError extends MoviesState {
  final String message;
  MoviesError(this.message);
}