import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/load_movies_usecase.dart';
import '../../domain/usecases/add_movie_usecase.dart';
import '../../domain/usecases/update_movie_usecase.dart';
import '../../domain/usecases/delete_movie_usecase.dart';
import 'movies_event.dart';
import 'movies_state.dart';

@injectable
class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  final LoadMoviesUseCase _loadMoviesUseCase;
  final AddMovieUseCase _addMovieUseCase;
  final UpdateMovieUseCase _updateMovieUseCase;
  final DeleteMovieUseCase _deleteMovieUseCase;

  MoviesBloc(
    this._loadMoviesUseCase,
    this._addMovieUseCase,
    this._updateMovieUseCase,
    this._deleteMovieUseCase,
  ) : super(MoviesInitial()) {
    on<LoadMovies>((event, emit) async {
      try {
        emit(MoviesLoading());
        final data = await _loadMoviesUseCase();
        emit(MoviesLoaded(
          data.movies,
          data.genres,
          data.ageRatings,
          data.directors,
          data.actors,
        ));
      } catch (e) {
        final msg = e is DioException ? (e.message ?? 'Došlo je do greške pri učitavanju filmova.') : e.toString();
        emit(MoviesError(msg));
      }
    });

    on<AddMovie>((event, emit) async {
      if (state is MoviesLoaded) {
        emit(MoviesLoading());
        try {
          await _addMovieUseCase(
            event.movie,
            posterPath: event.posterPath,
            mimeType: event.mimeType,
          );
          add(LoadMovies());
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
          await _updateMovieUseCase(
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
      if (state is! MoviesLoaded) return;

      final id = event.id;
      if (id == null || id.isEmpty) {
        emit(MoviesError('No movie id provided'));
        return;
      }

      emit(MoviesLoading());
      try {
        await _deleteMovieUseCase(id);
        add(LoadMovies());
      } catch (e) {
        final msg = e is DioException ? (e.message ?? 'Neuspješno brisanje filma.') : e.toString();
        emit(MoviesError(msg));
      }
    });
  }
}
