import '../../domain/repositories/movies_repository.dart';
import '../datasources/recommendations_api_service.dart';
import '../models/movie_score_dto.dart';

/// Implementation of RecommendationsRepository
class RecommendationsRepositoryImpl implements RecommendationsRepository {
  final RecommendationsApiService _recommendationsApiService;

  RecommendationsRepositoryImpl(this._recommendationsApiService);

  @override
  Future<List<MovieScoreDto>> getSimilar({required String movieId, int top = 10}) async {
    return await _recommendationsApiService.getSimilar(movieId: movieId, top: top);
  }

  @override
  Future<List<MovieScoreDto>> getMyRecommendations() async {
    return await _recommendationsApiService.getMyRecommendations();
  }
}

