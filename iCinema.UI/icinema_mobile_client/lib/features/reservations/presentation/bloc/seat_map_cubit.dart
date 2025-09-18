import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/reservation_api_service.dart';
import 'seat_map_state.dart';

class SeatMapCubit extends Cubit<SeatMapState> {
  final ReservationApiService _api;
  final String projectionId;

  SeatMapCubit(this._api, {required this.projectionId}) : super(SeatMapState.initial());

  Future<void> loadMap() async {
    emit(state.copyWith(loading: true, clearError: true, clearSuccess: true));
    try {
      final map = await _api.getSeatMap(projectionId);
      emit(state.copyWith(loading: false, map: map));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
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
      await _api.createReservation(
        projectionId: projectionId,
        seatIds: state.selectedSeatIds.toList(),
      );
      // success: refresh seat map and clear selection
      final map = await _api.getSeatMap(projectionId);
      emit(state.copyWith(
        reserving: false,
        map: map,
        selectedSeatIds: <String>{},
        successMessage: 'Rezervacija uspješna',
      ));
    } catch (e) {
      emit(state.copyWith(reserving: false, error: e.toString()));
      // On conflict, also refresh map to reflect latest status
      await loadMap();
    }
  }
}
