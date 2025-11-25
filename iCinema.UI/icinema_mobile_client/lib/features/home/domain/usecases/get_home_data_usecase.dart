import '../../data/models/projection_model.dart';
import '../../../movies/data/models/movie_score_dto.dart';
import '../repositories/home_repository.dart';

/// Use case for loading all home page data
class GetHomeDataUseCase {
  final HomeRepository _repository;

  GetHomeDataUseCase(this._repository);

  /// Execute loading all home data concurrently
  /// Returns a tuple of (todayProjections, upcomingProjections, groupedProjections, recommendations)
  Future<(
    List<ProjectionModel>,
    List<ProjectionModel>,
    Map<String, List<ProjectionModel>>,
    List<MovieScoreDto>,
  )> call() async {
    final results = await Future.wait([
      _repository.getTodayProjections(),
      _repository.getUpcomingProjections(),
      _repository.getGroupedProjections(),
      _repository.getMyRecommendations(),
    ]);

    return (
      results[0] as List<ProjectionModel>,
      results[1] as List<ProjectionModel>,
      results[2] as Map<String, List<ProjectionModel>>,
      results[3] as List<MovieScoreDto>,
    );
  }
}

