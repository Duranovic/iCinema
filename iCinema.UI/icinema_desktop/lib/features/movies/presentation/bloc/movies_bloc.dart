import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../data/movie_service.dart';
import '../../domain/movie.dart';
import 'movies_event.dart';
import 'movies_state.dart';

@injectable
class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  final MovieService movieService;

  MoviesBloc(this.movieService) : super(MoviesInitial()) {
    on<LoadMovies>((event, emit) async {
      try {
        emit(MoviesLoading());
        
        final results = await Future.wait([
          movieService.fetchMovies(),
          movieService.fetchGenres(),
          movieService.fetchAgeRatings(),
          movieService.fetchDirectors(),
          movieService.fetchActors(),
        ]);

        final movies = results[0] as List<Movie>;
        final genres = results[1];
        final ageRatings = results[2];
        final directors = results[3];
        final actors = results[4];

        emit(MoviesLoaded(movies, genres, ageRatings, directors, actors));
      } catch (e) {
        final msg = e is DioException ? (e.message ?? 'Došlo je do greške pri učitavanju filmova.') : e.toString();
        emit(MoviesError(msg));
      }
    });

    on<AddMovie>((event, emit) async {
      if (state is MoviesLoaded) {
        emit(MoviesLoading());
        try {
          await movieService.addMovie(
            event.movie,
            posterPath: event.posterPath,
            mimeType: event.mimeType,
          );
          add(LoadMovies()); // reload after add
        } catch (e) {
          final msg = e is DioException ? (e.message ?? 'Neuspješno dodavanje filma.') : e.toString();
          emit(MoviesError(msg));
        }
      }
    });

    on<UpdateMovie>((event, emit) async {
      if (state is MoviesLoaded) {
        emit(MoviesLoading());
        try {
          await movieService.updateMovie(
            event.movie,
            posterPath: event.posterPath,
            mimeType: event.mimeType,
          );
          add(LoadMovies());
        } catch (e) {
          final msg = e is DioException ? (e.message ?? 'Neuspješno ažuriranje filma.') : e.toString();
          emit(MoviesError(msg));
        }
      }
    });

    on<DeleteMovie>((event, emit) async {
      // Proceed only if movies are loaded; otherwise, ignore the delete.
      if (state is! MoviesLoaded) return;

      // Validate ID before showing loading state to avoid flicker on invalid input.
      final id = event.id;
      if (id == null || id.isEmpty) {
        emit(MoviesError('No movie id provided'));
        return;
      }

      emit(MoviesLoading());
      try {
        await movieService.deleteMovie(id);
        // Reload the movies after successful deletion.
        add(LoadMovies());
      } catch (e) {
        final msg = e is DioException ? (e.message ?? 'Neuspješno brisanje filma.') : e.toString();
        emit(MoviesError(msg));
      }
    });
  }
}
