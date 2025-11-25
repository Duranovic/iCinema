import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_api_service.dart';
import '../models/notification.dart';

/// Implementation of NotificationsRepository
class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsApiService _apiService;

  NotificationsRepositoryImpl(this._apiService);

  @override
  Future<List<NotificationModel>> getMy({int top = 50}) async {
    return await _apiService.getMy(top: top);
  }

  @override
  Future<void> markRead(String id) async {
    return await _apiService.markRead(id);
  }
}

