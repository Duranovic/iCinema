import '../repositories/movies_repository.dart';

/// Use case for getting user's rating for a movie
class GetMyRatingUseCase {
  final MoviesRepository _repository;

  GetMyRatingUseCase(this._repository);

  /// Execute getting user's rating
  Future<double?> call(String movieId) async {
    return await _repository.getMyRating(movieId);
  }
}

/// Use case for checking if user can rate a movie
class CanRateUseCase {
  final MoviesRepository _repository;

  CanRateUseCase(this._repository);

  /// Execute checking if user can rate
  Future<bool> call(String movieId) async {
    return await _repository.canRate(movieId);
  }
}

/// Use case for saving user's rating
class SaveRatingUseCase {
  final MoviesRepository _repository;

  SaveRatingUseCase(this._repository);

  /// Execute saving rating
  Future<void> call({
    required String movieId,
    required double rating,
    String? review,
  }) async {
    return await _repository.submitRating(movieId, rating, review);
  }
}

