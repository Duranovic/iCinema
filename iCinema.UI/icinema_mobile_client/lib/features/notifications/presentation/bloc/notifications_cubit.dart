import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import 'notifications_state.dart';
import '../../data/models/notification.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationReadUseCase _markNotificationReadUseCase;
  
  NotificationsCubit(
    this._getNotificationsUseCase,
    this._markNotificationReadUseCase,
  ) : super(const NotificationsInitial());

  Future<void> load({int top = 50}) async {
    emit(const NotificationsLoading());
    try {
      final items = await _getNotificationsUseCase(top: top);
      emit(NotificationsLoaded(items));
    } catch (e) {
      emit(NotificationsError('Greška pri učitavanju notifikacija.'));
    }
  }

  Future<void> markRead(String id) async {
    final current = state;
    if (current is NotificationsLoaded) {
      // optimistic update
      final List<NotificationModel> updated = current.items
          .map<NotificationModel>((n) => n.id == id
              ? NotificationModel(
                  id: n.id,
                  title: n.title,
                  message: n.message,
                  createdAt: n.createdAt,
                  isRead: true,
                )
              : n)
          .toList();
      emit(NotificationsLoaded(updated));
      try {
        await _markNotificationReadUseCase(id);
      } catch (_) {
        // rollback on failure
        emit(current);
      }
    }
  }

  Future<void> refresh() async {
    final current = state;
    try {
      final items = await _getNotificationsUseCase(top: 50);
      emit(NotificationsLoaded(items));
    } catch (_) {
      if (current is NotificationsLoaded) {
        emit(current); // keep old data
      } else {
        emit(NotificationsError('Greška pri osvježavanju notifikacija.'));
      }
    }
  }
}
