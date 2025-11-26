import '../../data/models/notification.dart';

/// Repository interface for notifications feature operations
abstract class NotificationsRepository {
  /// Get user's notifications
  Future<List<NotificationModel>> getMy({int top = 50});

  /// Mark notification as read
  Future<void> markRead(String id);

  /// Delete a notification
  Future<bool> delete(String id);

  /// Delete all notifications
  Future<int> deleteAll();
}

