import 'package:dio/dio.dart';
import '../models/notification.dart';

class NotificationsApiService {
  final Dio _dio;
  NotificationsApiService(this._dio);

  Future<List<NotificationModel>> getMy({int top = 50}) async {
    final resp = await _dio.get('/notifications/my', queryParameters: {
      'top': top,
    });
    final data = resp.data as List<dynamic>;
    return data
        .map((j) => NotificationModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(String id) async {
    await _dio.post('/notifications/$id/read');
  }

  Future<bool> delete(String id) async {
    final resp = await _dio.delete('/notifications/$id');
    return resp.statusCode == 200;
  }

  Future<int> deleteAll() async {
    final resp = await _dio.delete('/notifications');
    final data = resp.data as Map<String, dynamic>;
    return data['deleted'] as int? ?? 0;
  }
}
