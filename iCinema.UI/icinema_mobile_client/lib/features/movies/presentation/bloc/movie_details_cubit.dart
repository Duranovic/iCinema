import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/movie_model.dart';
import '../../data/services/movies_api_service.dart';
import '../../../home/data/models/projection_model.dart';
import '../../../home/data/services/projections_api_service.dart';

// States
abstract class MovieDetailsState {}

class MovieDetailsInitial extends MovieDetailsState {}

class MovieDetailsLoading extends MovieDetailsState {}

class MovieDetailsLoaded extends MovieDetailsState {
  final MovieModel movie;
  final List<ProjectionModel> projections;

  MovieDetailsLoaded({
    required this.movie,
    required this.projections,
  });
}

class MovieDetailsError extends MovieDetailsState {
  final String message;

  MovieDetailsError(this.message);
}

@injectable
class MovieDetailsCubit extends Cubit<MovieDetailsState> {
  final MoviesApiService _moviesApiService;
  final ProjectionsApiService _projectionsApiService;

  MovieDetailsCubit(this._moviesApiService, this._projectionsApiService)
      : super(MovieDetailsInitial());

  /// Load movie details and projections
  Future<void> loadMovieDetails(String movieId, List<ProjectionModel> projections) async {
    emit(MovieDetailsLoading());

    try {
      final movie = await _moviesApiService.getMovieById(movieId);
      final now = DateTime.now();
      // Always fetch complete (future) projections for this movie,
      // regardless of what was passed in via navigation extras. The extras
      // may represent only a single day and would hide other available days.
      List<ProjectionModel> finalProjections;
      final resp = await _projectionsApiService.getProjectionsForMovie(
        movieId: movieId,
        startDate: now,
      );
      finalProjections = resp.items.where((p) => p.startTime.isAfter(now)).toList();
      // In rare case backend returns empty, fallback to filtered provided list
      if (finalProjections.isEmpty && projections.isNotEmpty) {
        finalProjections = projections.where((p) => p.startTime.isAfter(now)).toList();
      }
      emit(MovieDetailsLoaded(movie: movie, projections: finalProjections));
    } on MovieNotFoundException {
      emit(MovieDetailsError('Film nije pronađen'));
    } on MoviesNetworkException catch (e) {
      emit(MovieDetailsError('Greška mreže: ${e.message}'));
    } on MoviesUnknownException catch (e) {
      emit(MovieDetailsError('Neočekivana greška: ${e.message}'));
    } catch (e) {
      emit(MovieDetailsError('Greška pri učitavanju filma: $e'));
    }
  }

  /// Refresh movie details
  Future<void> refreshMovieDetails(String movieId, List<ProjectionModel> projections) async {
    await loadMovieDetails(movieId, projections);
  }

  /// Helper method to get movie from current state
  MovieModel? get currentMovie {
    final state = this.state;
    if (state is MovieDetailsLoaded) {
      return state.movie;
    }
    return null;
  }

  /// Helper method to get projections from current state
  List<ProjectionModel> get currentProjections {
    final state = this.state;
    if (state is MovieDetailsLoaded) {
      return state.projections;
    }
    return [];
  }

  /// Helper method to check if currently loading
  bool get isLoading => state is MovieDetailsLoading;

  /// Helper method to check if there's an error
  bool get hasError => state is MovieDetailsError;

  /// Helper method to get error message
  String? get errorMessage {
    final state = this.state;
    if (state is MovieDetailsError) {
      return state.message;
    }
    return null;
  }
}
