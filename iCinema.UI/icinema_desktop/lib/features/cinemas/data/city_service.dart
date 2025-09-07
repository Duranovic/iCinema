import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../domain/city.dart';

@lazySingleton
class CityService {
  final Dio _dio;
  CityService(this._dio);

  Future<List<City>> fetchCities() async {
    final res = await _dio.get('/cities');
    final items = res.data['items'] as List<dynamic>? ?? res.data as List<dynamic>;
    return items.map((e) => City.fromJson(e)).toList();
  }
}
