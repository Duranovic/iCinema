import 'dart:async';

/// Simple global bus to notify seat map screens to reload.
/// We don't carry projectionId for now; all active seat maps will refresh.
class SeatMapRefreshBus {
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
