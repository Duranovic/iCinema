import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../domain/movie.dart';
import 'dart:convert';
import 'dart:io';

@lazySingleton
class MovieService {
  final Dio _dio;
  MovieService(this._dio);

  Future<List<Movie>> fetchMovies() async {
    try {
      final res = await _dio.get('/movies');

      final items = res.data['items'] as List<dynamic>;
      final movies = items.map((e) => Movie.fromJson(e)).toList();
      return movies;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> fetchGenres() async {
    final res = await _dio.get('/genres');
    final items = res.data['items'] as List<dynamic>;
    return items;
  }

  Future<Movie> addMovie(Movie movie, {String? posterPath, String? mimeType}) async {
    final payload = await _createMovieJsonPayload(movie, posterPath: posterPath, mimeType: mimeType);
    final res = await _dio.post('/movies', data: payload);
    return Movie.fromJson(res.data);
  }

  Future<Movie> updateMovie(Movie movie, {String? posterPath, String? mimeType}) async {
    final payload = await _createMovieJsonPayload(movie, posterPath: posterPath, mimeType: mimeType);
    final res = await _dio.put('/movies/${movie.id}', data: payload);
    return Movie.fromJson(res.data);
  }

  Future<void> deleteMovie(String id) async {
    await _dio.delete('/movies/$id');
  }

  Future<Map<String, dynamic>> _createMovieJsonPayload(
    Movie movie, {
    String? posterPath,
    String? mimeType,
  }) async {
    final map = Map<String, dynamic>.from(movie.toJson());

    if (posterPath != null && posterPath.isNotEmpty) {
      // Read file and encode as base64
      final file = File(posterPath);
      final bytes = await file.readAsBytes();
      final b64 = base64Encode(bytes);

      map['posterBase64'] = b64;
      if (mimeType != null && mimeType.isNotEmpty) {
        map['posterMimeType'] = mimeType;
      }
    }

    return map;
  }
}