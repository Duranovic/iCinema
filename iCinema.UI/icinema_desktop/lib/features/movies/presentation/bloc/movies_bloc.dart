import 'package:flutter_bloc/flutter_bloc.dart';
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
        ]);

        final movies = results[0] as List<Movie>;
        final genres = results[1];

        emit(MoviesLoaded(movies, genres));
      } catch (e) {
        emit(MoviesError('Failed to load movies'));
      }
    });

    on<AddMovie>((event, emit) async {
      if (state is MoviesLoaded) {
        emit(MoviesLoading());
        try {
          await movieService.addMovie(event.movie);
          add(LoadMovies()); // reload after add
        } catch (e) {
          emit(MoviesError('Failed to add movie'));
        }
      }
    });

    on<UpdateMovie>((event, emit) async {
      if (state is MoviesLoaded) {
        emit(MoviesLoading());
        try {
          await movieService.updateMovie(event.movie);
          add(LoadMovies());
        } catch (e) {
          emit(MoviesError('Failed to update movie'));
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
        emit(MoviesError('Failed to delete movie'));
      }
    });
  }
}
