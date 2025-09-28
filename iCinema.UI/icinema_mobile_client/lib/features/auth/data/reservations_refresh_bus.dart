import 'dart:async';

/// Global bus to notify profile reservations lists to refresh after changes
class ReservationsRefreshBus {
  final StreamController<void> _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notify() {
    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }

  void dispose() {
    _controller.close();
  }
}
