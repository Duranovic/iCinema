import '../../data/models/movie_score_dto.dart';
import '../repositories/movies_repository.dart';

/// Use case for getting similar movies
class GetSimilarMoviesUseCase {
  final RecommendationsRepository _repository;

  GetSimilarMoviesUseCase(this._repository);

  /// Execute getting similar movies
  Future<List<MovieScoreDto>> call({required String movieId, int top = 10}) async {
    return await _repository.getSimilar(movieId: movieId, top: top);
  }
}



