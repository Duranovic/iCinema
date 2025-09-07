import 'package:dio/dio.dart';
import 'package:icinema_desktop/features/projections/domain/cinema.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CinemaService {
  final Dio _dio;
  CinemaService(this._dio);

  Future<List<Cinema>> fetchCinemas() async {
    final res = await _dio.get('/cinemas');
    final items = res.data['items'] as List<dynamic>;
    return items.map((e) => Cinema.fromJson(e)).toList();
  }
}
