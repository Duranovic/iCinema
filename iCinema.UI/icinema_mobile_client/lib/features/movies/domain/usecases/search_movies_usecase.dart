import '../repositories/movies_repository.dart';

/// Use case for searching movies
class SearchMoviesUseCase {
  final SearchRepository _repository;

  SearchMoviesUseCase(this._repository);

  /// Execute movie search
  Future<SearchResult> call({
    required String search,
    int page = 1,
    int pageSize = 20,
    String? genreId,
    String? cinemaId,
    String? cityId,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? sortBy,
    bool descending = false,
  }) async {
    return await _repository.searchMovies(
      search: search,
      page: page,
      pageSize: pageSize,
      genreId: genreId,
      cinemaId: cinemaId,
      cityId: cityId,
      dateFrom: dateFrom,
      dateTo: dateTo,
      sortBy: sortBy,
      descending: descending,
    );
  }
}

