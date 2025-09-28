import '../../data/models/notification.dart';

sealed class NotificationsState {
  const NotificationsState();
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> items;
  final int unreadCount;
  NotificationsLoaded(this.items)
      : unreadCount = items.where((n) => !n.isRead).length;
}

class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);
}
