import '../../data/models/projection_model.dart';
import '../../../movies/data/models/movie_score_dto.dart';

/// Repository interface for home feature operations
abstract class HomeRepository {
  Future<List<ProjectionModel>> getTodayProjections();
  Future<List<ProjectionModel>> getUpcomingProjections();
  Future<Map<String, List<ProjectionModel>>> getGroupedProjections();
  Future<List<MovieScoreDto>> getMyRecommendations();
}

