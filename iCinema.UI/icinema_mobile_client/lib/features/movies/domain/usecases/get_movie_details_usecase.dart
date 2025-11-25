import '../../../home/data/models/projection_model.dart';
import '../../../home/data/datasources/projections_api_service.dart';
import '../../data/models/movie_model.dart';
import '../repositories/movies_repository.dart';

/// Use case for loading complete movie details (movie + projections + rating info)
class GetMovieDetailsUseCase {
  final MoviesRepository _moviesRepository;
  final ProjectionsApiService _projectionsApiService;

  GetMovieDetailsUseCase(this._moviesRepository, this._projectionsApiService);

  /// Execute loading movie details
  /// Returns a tuple of (movie, projections, myRating, canRate)
  Future<(
    MovieModel,
    List<ProjectionModel>,
    double?,
    bool,
  )> call({
    required String movieId,
    required DateTime now,
    List<ProjectionModel>? fallbackProjections,
  }) async {
    // Load movie
    final movie = await _moviesRepository.getMovieById(movieId);

    // Load projections for this movie
    final resp = await _projectionsApiService.getProjectionsForMovie(
      movieId: movieId,
      startDate: now,
    );
    List<ProjectionModel> finalProjections = resp.items.where((p) => p.startTime.isAfter(now)).toList();
    
    // Fallback to provided projections if API returns empty
    if (finalProjections.isEmpty && fallbackProjections != null && fallbackProjections.isNotEmpty) {
      finalProjections = fallbackProjections.where((p) => p.startTime.isAfter(now)).toList();
    }

    // Load rating and canRate concurrently
    double? myRating;
    bool canRate = false;
    
    try {
      final results = await Future.wait([
        _moviesRepository.getMyRating(movieId).catchError((_) => null),
        _moviesRepository.canRate(movieId).catchError((_) => false),
      ], eagerError: false);
      
      myRating = results[0] as double?;
      canRate = results[1] as bool? ?? false;
    } catch (_) {
      // If rating check fails, continue without it
      myRating = null;
      canRate = false;
    }

    return (movie, finalProjections, myRating, canRate);
  }
}

