import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icinema_shared/icinema_shared.dart';
import '../../data/models/projection_model.dart';
import '../../data/datasources/projections_api_service.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import '../../../movies/data/models/movie_score_dto.dart';

// Home State
abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<ProjectionModel> featuredProjections;
  final List<ProjectionModel> todayProjections;
  final List<ProjectionModel> upcomingProjections;
  final Map<String, List<ProjectionModel>> groupedByMovie;
  final List<MovieScoreDto> recommendations;

  const HomeLoaded({
    required this.featuredProjections,
    required this.todayProjections,
    required this.upcomingProjections,
    required this.groupedByMovie,
    required this.recommendations,
  });

  HomeLoaded copyWith({
    List<ProjectionModel>? featuredProjections,
    List<ProjectionModel>? todayProjections,
    List<ProjectionModel>? upcomingProjections,
    Map<String, List<ProjectionModel>>? groupedByMovie,
    List<MovieScoreDto>? recommendations,
  }) {
    return HomeLoaded(
      featuredProjections: featuredProjections ?? this.featuredProjections,
      todayProjections: todayProjections ?? this.todayProjections,
      upcomingProjections: upcomingProjections ?? this.upcomingProjections,
      groupedByMovie: groupedByMovie ?? this.groupedByMovie,
      recommendations: recommendations ?? this.recommendations,
    );
  }
}

class HomeError extends HomeState {
  final String message;
  final String? errorType;

  const HomeError({
    required this.message,
    this.errorType,
  });
}

// Home Cubit
class HomeCubit extends Cubit<HomeState> {
  final GetHomeDataUseCase _getHomeDataUseCase;

  HomeCubit(this._getHomeDataUseCase) : super(const HomeInitial());

  Future<void> loadHomeData() async {
    emit(const HomeLoading());
    
    try {
      // Load all data concurrently for better performance
      final (
        todayProjections,
        upcomingProjections,
        groupedProjections,
        recommendations,
      ) = await _getHomeDataUseCase();

      // Create featured projections from today's projections
      // Take the first 3 unique movies for the slider
      final featuredProjections = _createFeaturedProjections(todayProjections, upcomingProjections);

      emit(HomeLoaded(
        featuredProjections: featuredProjections,
        todayProjections: todayProjections,
        upcomingProjections: upcomingProjections,
        groupedByMovie: groupedProjections,
        recommendations: recommendations,
      ));
    } on ProjectionsNotFoundException {
      emit(const HomeError(
        message: 'Nema dostupnih projekcija u ovom periodu.',
        errorType: 'not_found',
      ));
    } on ProjectionsNetworkException {
      emit(const HomeError(
        message: 'Greška u mrežnoj konekciji. Molimo pokušajte ponovo.',
        errorType: 'network',
      ));
    } on ProjectionsServerException {
      emit(const HomeError(
        message: 'Greška na serveru. Molimo pokušajte kasnije.',
        errorType: 'server',
      ));
    } catch (e) {
      emit(HomeError(
        message: ErrorHandler.getMessage(e),
        errorType: 'unknown',
      ));
    }
  }

  Future<void> refreshHomeData() async {
    // Don't show loading state for refresh, just reload data
    try {
      final (
        todayProjections,
        upcomingProjections,
        groupedProjections,
        recommendations,
      ) = await _getHomeDataUseCase();

      final featuredProjections = _createFeaturedProjections(todayProjections, upcomingProjections);

      emit(HomeLoaded(
        featuredProjections: featuredProjections,
        todayProjections: todayProjections,
        upcomingProjections: upcomingProjections,
        groupedByMovie: groupedProjections,
        recommendations: recommendations,
      ));
    } catch (e) {
      // If refresh fails, keep the current state and show a snackbar or toast
      // The UI can handle this by checking if the state is still HomeLoaded
    }
  }

  List<ProjectionModel> _createFeaturedProjections(
    List<ProjectionModel> todayProjections,
    List<ProjectionModel> upcomingProjections,
  ) {
    final allProjections = [...todayProjections, ...upcomingProjections];
    final uniqueMovies = <String, ProjectionModel>{};

    // Get unique movies, preferring today's projections
    for (final projection in allProjections) {
      if (!uniqueMovies.containsKey(projection.movieTitle)) {
        uniqueMovies[projection.movieTitle] = projection;
      }
    }

    // Return up to 5 featured movies for the slider
    return uniqueMovies.values.take(5).toList();
  }

  // Helper methods for UI
  List<ProjectionModel> getTodayProjectionsForMovie(String movieTitle) {
    final currentState = state;
    if (currentState is HomeLoaded) {
      return currentState.todayProjections
          .where((p) => p.movieTitle == movieTitle)
          .toList();
    }
    return [];
  }

  List<ProjectionModel> getUpcomingProjectionsForMovie(String movieTitle) {
    final currentState = state;
    if (currentState is HomeLoaded) {
      return currentState.upcomingProjections
          .where((p) => p.movieTitle == movieTitle)
          .toList();
    }
    return [];
  }

  List<String> getUniqueMovieTitles() {
    final currentState = state;
    if (currentState is HomeLoaded) {
      return currentState.groupedByMovie.keys.toList();
    }
    return [];
  }
}
