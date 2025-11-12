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

  Future<List<dynamic>> fetchAgeRatings() async {
    final res = await _dio.get('/Metadata/age-ratings');
    // Expecting a plain JSON array: [{"code":"G","label":"..."}, ...]
    final data = res.data as List<dynamic>;
    return data;
  }

  Future<List<dynamic>> fetchDirectors() async {
    final res = await _dio.get('/Metadata/directors');
    // Expecting a plain JSON array: [{"id":"...","fullName":"..."}, ...]
    final data = res.data as List<dynamic>;
    return data;
  }

  Future<List<dynamic>> fetchActors() async {
    // Lightweight items list for dropdowns: [{id, fullName}]
    final res = await _dio.get('/Actors/items');
    final data = res.data as List<dynamic>;
    return data;
  }

  Future<Movie> addMovie(Movie movie, {String? posterPath, String? mimeType}) async {
    final payload = await _createMovieJsonPayload(movie, posterPath: posterPath, mimeType: mimeType);
    final res = await _dio.post('/movies', data: payload);
    final created = Movie.fromJson(res.data);
    if ((movie.actorIds).isNotEmpty && created.id != null && created.id!.isNotEmpty) {
      await addCast(created.id!, movie.actorIds);
    }
    return created;
  }

  Future<Movie> updateMovie(Movie movie, {String? posterPath, String? mimeType}) async {
    final payload = await _createMovieJsonPayload(movie, posterPath: posterPath, mimeType: mimeType);
    final res = await _dio.put('/movies/${movie.id}', data: payload);
    final updated = Movie.fromJson(res.data);
    if ((movie.actorIds).isNotEmpty && updated.id != null && updated.id!.isNotEmpty) {
      // For simplicity, we replace cast: remove all, then add new set.
      // Fetch existing and remove differences could be added later if needed.
      final existing = await getCast(updated.id!);
      for (final c in existing) {
        final actorId = (c['actorId'] as String?);
        if (actorId != null && !movie.actorIds.contains(actorId)) {
          await removeCast(updated.id!, actorId);
        }
      }
      await addCast(updated.id!, movie.actorIds);
    }
    return updated;
  }

  Future<void> deleteMovie(String id) async {
    await _dio.delete('/movies/$id');
  }

  // ---- Cast management helpers ----
  Future<List<Map<String, dynamic>>> getCast(String movieId) async {
    final res = await _dio.get('/movies/$movieId/cast');
    final list = (res.data as List<dynamic>).whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    return list;
  }

  Future<void> addCast(String movieId, List<String> actorIds) async {
    if (actorIds.isEmpty) return;
    final items = actorIds.map((id) => {'actorId': id}).toList();
    await _dio.post('/movies/$movieId/cast', data: {'items': items});
  }

  Future<void> updateCastRole(String movieId, String actorId, {String? roleName}) async {
    await _dio.put('/movies/$movieId/cast/$actorId', data: {'roleName': roleName});
  }

  Future<void> removeCast(String movieId, String actorId) async {
    await _dio.delete('/movies/$movieId/cast/$actorId');
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