import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../domain/movie.dart';

@lazySingleton
class MovieService {
  final Dio _dio;
  MovieService(this._dio);

  Future<List<Movie>> fetchMovies() async {
    final res = await _dio.get('/movies');
    final items = res.data['items'] as List<dynamic>;
    return items.map((e) => Movie.fromJson(e)).toList();
  }

  Future<List<dynamic>> fetchGenres() async {
    final res = await _dio.get('/genres');
    final items = res.data['items'] as List<dynamic>;
    return items;
  }

  Future<Movie> addMovie(Movie movie) async {
    final res = await _dio.post('/movies', data: movie.toJson());
    return Movie.fromJson(res.data);
  }

  Future<Movie> updateMovie(Movie movie) async {
    final res = await _dio.put('/movies/${movie.id}', data: movie.toJson());
    return Movie.fromJson(res.data);
  }

  Future<void> deleteMovie(String id) async {
    await _dio.delete('/movies/$id');
  }
}