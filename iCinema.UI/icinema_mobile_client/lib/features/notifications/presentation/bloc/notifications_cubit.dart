import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import 'notifications_state.dart';
import '../../data/models/notification.dart';
import '../../../../app/services/signalr_service.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationReadUseCase _markNotificationReadUseCase;
  final SignalRService? _signalRService;
  StreamSubscription<Map<String, dynamic>>? _signalRSubscription;
  
  NotificationsCubit(
    this._getNotificationsUseCase,
    this._markNotificationReadUseCase, [
    this._signalRService,
  ]) : super(const NotificationsInitial()) {
    _subscribeToSignalR();
  }
  
  void _subscribeToSignalR() {
    if (_signalRService == null) return;
    
    _signalRSubscription = _signalRService!.notificationStream.listen((data) {
      _handleNewNotification(data);
    });
  }
  
  void _handleNewNotification(Map<String, dynamic> data) {
    try {
      final notification = NotificationModel(
        id: data['id']?.toString() ?? '',
        title: data['title']?.toString() ?? '',
        message: data['message']?.toString() ?? '',
        createdAt: data['createdAt'] != null 
            ? DateTime.parse(data['createdAt'].toString())
            : DateTime.now(),
        isRead: data['isRead'] as bool? ?? false,
      );
      
      final current = state;
      if (current is NotificationsLoaded) {
        // Add new notification at the beginning
        final updated = [notification, ...current.items];
        emit(NotificationsLoaded(updated));
      } else {
        // If not loaded yet, just load
        load();
      }
    } catch (e) {
      print('Error handling SignalR notification: $e');
    }
  }

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
  
  @override
  Future<void> close() {
    _signalRSubscription?.cancel();
    return super.close();
  }
}
