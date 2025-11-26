import '../../data/models/notification.dart';
import '../repositories/notifications_repository.dart';

/// Use case for getting notifications
class GetNotificationsUseCase {
  final NotificationsRepository _repository;

  GetNotificationsUseCase(this._repository);

  /// Execute getting notifications
  Future<List<NotificationModel>> call({int top = 50}) async {
    return await _repository.getMy(top: top);
  }
}

/// Use case for marking notification as read
class MarkNotificationReadUseCase {
  final NotificationsRepository _repository;

  MarkNotificationReadUseCase(this._repository);

  /// Execute marking notification as read
  Future<void> call(String id) async {
    return await _repository.markRead(id);
  }
}

/// Use case for deleting a notification
class DeleteNotificationUseCase {
  final NotificationsRepository _repository;

  DeleteNotificationUseCase(this._repository);

  /// Execute deleting notification
  Future<bool> call(String id) async {
    return await _repository.delete(id);
  }
}

/// Use case for deleting all notifications
class DeleteAllNotificationsUseCase {
  final NotificationsRepository _repository;

  DeleteAllNotificationsUseCase(this._repository);

  /// Execute deleting all notifications
  Future<int> call() async {
    return await _repository.deleteAll();
  }
}

