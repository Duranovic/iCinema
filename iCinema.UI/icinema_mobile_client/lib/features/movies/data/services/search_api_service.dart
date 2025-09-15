import 'package:dio/dio.dart';
import '../models/movie_model.dart';

class PagedResult<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;

  const PagedResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });
}

class SearchApiService {
  final Dio _dio;

  SearchApiService(this._dio);

  Future<PagedResult<MovieModel>> searchMovies({
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
    final Map<String, dynamic> queryParams = {
      'search': search,
      'page': page,
      'pageSize': pageSize,
      if (genreId != null && genreId.isNotEmpty) 'genreId': genreId,
      if (cinemaId != null && cinemaId.isNotEmpty) 'cinemaId': cinemaId,
      if (cityId != null && cityId.isNotEmpty) 'cityId': cityId,
      if (dateFrom != null) 'dateFrom': dateFrom.toIso8601String(),
      if (dateTo != null) 'dateTo': dateTo.toIso8601String(),
      if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      'descending': descending,
    };

    final response = await _dio.get('/movies', queryParameters: queryParams);

    final data = response.data as Map<String, dynamic>;
    final itemsJson = (data['items'] as List<dynamic>? ?? <dynamic>[]);

    final movies = itemsJson
        .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PagedResult<MovieModel>(
      items: movies,
      total: data['total'] as int? ?? movies.length,
      page: data['page'] as int? ?? page,
      pageSize: data['pageSize'] as int? ?? pageSize,
    );
  }
}
