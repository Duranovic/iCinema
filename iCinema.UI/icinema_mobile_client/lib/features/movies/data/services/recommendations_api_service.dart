import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/movie_score_dto.dart';

@injectable
class RecommendationsApiService {
  final Dio _dio;

  const RecommendationsApiService(this._dio);

  Future<List<MovieScoreDto>> getSimilar({required String movieId, int top = 10}) async {
    try {
      final resp = await _dio.get('/Recommendations/similar/$movieId', queryParameters: {
        'top': top,
      });
      if (resp.statusCode == 200) {
        final data = resp.data as List<dynamic>;
        return data.map((e) => MovieScoreDto.fromJson(e as Map<String, dynamic>)).toList();
      }
      return const <MovieScoreDto>[];
    } on DioException catch (e) {
      // Bubble up as a generic exception; UI will handle
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
