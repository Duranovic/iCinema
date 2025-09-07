import 'package:dio/dio.dart';
import 'package:icinema_desktop/features/projections/domain/projection.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ProjectionService {
  final Dio _dio;
  ProjectionService(this._dio);

  Future<List<Projection>> fetchProjections({DateTime? date, bool disablePaging = true, String? cinemaId}) async {
    final query = <String, dynamic>{
      'DisablePaging': disablePaging,
      'SortBy': 'StartTime', // Sort by StartTime for chronological order (PascalCase)
      if (cinemaId != null) 'CinemaId': cinemaId,
    };
    
    // If date is provided, send month range instead of exact date
    if (date != null) {
      // Get first day of the month
      final startOfMonth = DateTime(date.year, date.month, 1);
      // Get first day of next month (end of current month)
      final endOfMonth = DateTime(date.year, date.month + 1, 1);
      
      query['StartDate'] = startOfMonth.toIso8601String();
      query['EndDate'] = endOfMonth.toIso8601String();
    }
    
    final res = await _dio.get('/projections', queryParameters: query);
    final items = res.data['items'] as List<dynamic>;
    return items.map((e) => Projection.fromJson(e)).toList();
  }

  Future<Projection> addProjection(Projection projection) async {
    final res = await _dio.post('/projections', data: projection.toJson());
    return Projection.fromJson(res.data);
  }

  Future<Projection> updateProjection(Projection projection) async {
    final res = await _dio.put('/projections/${projection.id}', data: projection.toJson());
    return Projection.fromJson(res.data);
  }

  Future<void> deleteProjection(String id) async {
    await _dio.delete('/projections/$id');
  }
}