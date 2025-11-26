import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:icinema_shared/icinema_shared.dart';
import '../../data/models/movie_model.dart';
import '../../domain/usecases/get_my_rating_usecase.dart';
import '../../domain/usecases/get_movie_details_usecase.dart';
import '../../data/datasources/movies_api_service.dart';
import '../../../home/data/models/projection_model.dart';

// States
abstract class MovieDetailsState {}

class MovieDetailsInitial extends MovieDetailsState {}

class MovieDetailsLoading extends MovieDetailsState {}

class MovieDetailsLoaded extends MovieDetailsState {
  final MovieModel movie;
  final List<ProjectionModel> projections;
  final double? myRating;
  final bool canRate;

  MovieDetailsLoaded({
    required this.movie,
    required this.projections,
    this.myRating,
    this.canRate = false,
  });

  MovieDetailsLoaded copyWith({
    MovieModel? movie,
    List<ProjectionModel>? projections,
    double? myRating,
    bool? canRate,
  }) => MovieDetailsLoaded(
        movie: movie ?? this.movie,
        projections: projections ?? this.projections,
        myRating: myRating ?? this.myRating,
        canRate: canRate ?? this.canRate,
      );
}

class MovieDetailsError extends MovieDetailsState {
  final String message;

  MovieDetailsError(this.message);
}

@injectable
class MovieDetailsCubit extends Cubit<MovieDetailsState> {
  final GetMovieDetailsUseCase _getMovieDetailsUseCase;
  final GetMyRatingUseCase _getMyRatingUseCase;
  final SaveRatingUseCase _saveRatingUseCase;
  final CanRateUseCase _canRateUseCase;

  MovieDetailsCubit(
    this._getMovieDetailsUseCase,
    this._getMyRatingUseCase,
    this._saveRatingUseCase,
    this._canRateUseCase,
  ) : super(MovieDetailsInitial());

  /// Load movie details and projections
  Future<void> loadMovieDetails(String movieId, List<ProjectionModel> projections) async {
    emit(MovieDetailsLoading());

    try {
      final now = DateTime.now();
      final (movie, finalProjections, myRating, canRate) = await _getMovieDetailsUseCase(
        movieId: movieId,
        now: now,
        fallbackProjections: projections,
      );

      // Emit loaded state
      emit(MovieDetailsLoaded(
        movie: movie,
        projections: finalProjections,
        myRating: myRating,
        canRate: canRate,
      ));
    } on MovieNotFoundException {
      emit(MovieDetailsError('Film nije pronađen'));
    } on MoviesNetworkException catch (e) {
      emit(MovieDetailsError('Greška mreže: ${e.message}'));
    } on MoviesUnknownException catch (e) {
      emit(MovieDetailsError('Neočekivana greška: ${e.message}'));
    } catch (e) {
      emit(MovieDetailsError(ErrorHandler.getMessage(e)));
    }
  }

  /// Check if user can rate (must have purchased a ticket)
  Future<void> loadCanRate(String movieId) async {
    try {
      final allowed = await _canRateUseCase(movieId);
      final s = state;
      if (s is MovieDetailsLoaded) {
        emit(s.copyWith(canRate: allowed));
      }
    } catch (_) {
      final s = state;
      if (s is MovieDetailsLoaded) emit(s.copyWith(canRate: false));
    }
  }

  /// Load current user's rating, if any
  Future<void> loadMyRating(String movieId) async {
    try {
      final rating = await _getMyRatingUseCase(movieId);
      final s = state;
      if (s is MovieDetailsLoaded) {
        emit(s.copyWith(myRating: rating));
      }
    } catch (_) {
      // ignore rating failures; keep UI functional
    }
  }

  /// Save current user's rating. Optimistically update average/count.
  Future<void> saveMyRating({required String movieId, required double rating, String? review}) async {
    final s = state;
    if (s is! MovieDetailsLoaded) return;
    if (!s.canRate) return; // guard: cannot rate without purchase

    // Keep previous values for potential rollback
    final prevState = s;
    double? prevMy = s.myRating;
    final prevMovie = s.movie;

    // Backend expects 1..5; clamp and use the same value for optimistic UI
    final double r = rating.round().clamp(1, 5).toDouble();

    // Optimistic math
    final oldAvg = prevMovie.averageRating ?? 0.0;
    final oldCount = prevMovie.ratingsCount ?? 0;
    double newAvg;
    int newCount = oldCount;
    if (prevMy == null) {
      // new rating from this user
      newCount = oldCount + 1;
      newAvg = ((oldAvg * oldCount) + r) / (newCount == 0 ? 1 : newCount);
    } else {
      // update existing rating
      newAvg = ((oldAvg * oldCount) - prevMy + r) / (oldCount == 0 ? 1 : oldCount);
    }

    emit(s.copyWith(
      myRating: r,
      movie: prevMovie.copyWith(
        averageRating: double.parse(newAvg.toStringAsFixed(2)),
        ratingsCount: newCount,
      ),
    ));

    try {
      await _saveRatingUseCase(movieId: movieId, rating: r, review: review);
      // Optionally refresh from server in background later if needed
    } catch (e) {
      // Rollback on failure
      emit(prevState);
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
