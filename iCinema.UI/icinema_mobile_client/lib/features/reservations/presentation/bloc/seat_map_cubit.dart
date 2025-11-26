import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icinema_shared/icinema_shared.dart';
import '../../domain/usecases/get_seat_map_usecase.dart';
import 'seat_map_state.dart';
import '../../data/seat_map_refresh_bus.dart';
import '../../../../app/di/injection.dart';
import 'dart:async';

class SeatMapCubit extends Cubit<SeatMapState> {
  final GetSeatMapUseCase _getSeatMapUseCase;
  final CreateReservationUseCase _createReservationUseCase;
  final String projectionId;
  StreamSubscription<void>? _refreshSub;

  SeatMapCubit(
    this._getSeatMapUseCase,
    this._createReservationUseCase, {
    required this.projectionId,
  }) : super(SeatMapState.initial());

  Future<void> loadMap() async {
    emit(state.copyWith(loading: true, clearError: true, clearSuccess: true));
    try {
      final map = await _getSeatMapUseCase(projectionId);
      emit(state.copyWith(loading: false, map: map));
    } catch (e) {
      emit(state.copyWith(loading: false, error: ErrorHandler.getMessage(e)));
    }
  }

  void toggleSeat(String seatId, {required bool isTaken}) {
    if (isTaken) return; // cannot select taken seats
    final next = Set<String>.from(state.selectedSeatIds);
    if (!next.add(seatId)) {
      next.remove(seatId);
    }
    emit(state.copyWith(selectedSeatIds: next, clearError: true, clearSuccess: true));
  }

  Future<void> reserve() async {
    if (state.selectedSeatIds.isEmpty) return;
    emit(state.copyWith(reserving: true, clearError: true, clearSuccess: true));
    try {
      final created = await _createReservationUseCase(
        projectionId: projectionId,
        seatIds: state.selectedSeatIds.toList(),
      );
      // success: refresh seat map and clear selection
      final map = await _getSeatMapUseCase(projectionId);
      emit(state.copyWith(
        reserving: false,
        map: map,
        selectedSeatIds: <String>{},
        successMessage: 'Rezervacija uspješna',
        lastReservationId: created.reservationId,
      ));
    } catch (e) {
      emit(state.copyWith(reserving: false, error: ErrorHandler.getMessage(e)));
      // On conflict, also refresh map to reflect latest status
      await loadMap();
    }
  }

  void acknowledgeNavigationHandled() {
    emit(state.copyWith(clearReservationId: true));
  }

  // Wire up bus subscription when first used
  void ensureRefreshSubscription() {
    if (_refreshSub != null) return;
    if (getIt.isRegistered<SeatMapRefreshBus>()) {
      _refreshSub = getIt<SeatMapRefreshBus>().stream.listen((_) {
        // If this seat map is shown for the same projection, refresh
        // We don't carry projectionId in the event for now; refresh anyway
        loadMap();
      });
    }
  }

  @override
  Future<void> close() async {
    await _refreshSub?.cancel();
    return super.close();
  }
}
