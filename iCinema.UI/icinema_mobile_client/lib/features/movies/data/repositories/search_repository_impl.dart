import '../../domain/repositories/movies_repository.dart';
import '../datasources/search_api_service.dart';
import '../models/movie_model.dart';

/// Implementation of SearchRepository
class SearchRepositoryImpl implements SearchRepository {
  final SearchApiService _searchApiService;

  SearchRepositoryImpl(this._searchApiService);

  @override
  Future<SearchResult> searchMovies({
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
    final result = await _searchApiService.searchMovies(
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
    
    return SearchResult(
      items: result.items,
      total: result.total,
      page: result.page,
      pageSize: result.pageSize,
    );
  }
}

