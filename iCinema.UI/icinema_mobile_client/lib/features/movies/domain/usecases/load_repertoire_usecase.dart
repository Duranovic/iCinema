import '../../../home/data/models/projection_model.dart';
import '../../../home/data/datasources/projections_api_service.dart';
import '../../data/models/movie_model.dart';
import '../repositories/movies_repository.dart';

/// Use case for loading movie repertoire (projections + movie details)
class LoadRepertoireUseCase {
  final ProjectionsApiService _projectionsApiService;
  final MoviesRepository _moviesRepository;

  LoadRepertoireUseCase(this._projectionsApiService, this._moviesRepository);

  /// Execute loading repertoire for a date range
  /// Returns a tuple of (projections, moviesById)
  Future<(
    List<ProjectionModel>,
    Map<String, MovieModel>,
  )> call({
    required DateTime from,
    required DateTime to,
  }) async {
    // Get projections for the date range
    final resp = await _projectionsApiService.getProjectionsInRange(
      startDate: from,
      endDate: to,
    );

    // Fetch movie details for unique movieIds
    final uniqueMovieIds = resp.items.map((p) => p.movieId).where((id) => id.isNotEmpty).toSet().toList();
    Map<String, MovieModel> moviesById = {};
    
    if (uniqueMovieIds.isNotEmpty) {
      final movies = await _moviesRepository.getMoviesByIds(uniqueMovieIds);
      moviesById = {for (final m in movies) m.id: m};
    }

    return (resp.items, moviesById);
  }
}

