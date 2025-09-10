import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'home_kpis_dto.dart';

@lazySingleton
class HomeService {
  final Dio _dio;
  HomeService(this._dio);

  Future<HomeKpisDto> getKpis() async {
    final res = await _dio.get('/home/kpis');
    return HomeKpisDto.fromJson(res.data as Map<String, dynamic>);
  }
}
