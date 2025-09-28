import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/reservation_api_service.dart';
import 'reservation_details_state.dart';
import '../../data/seat_map_refresh_bus.dart';
import '../../../../app/di/injection.dart';
import '../../../auth/data/reservations_refresh_bus.dart';

class ReservationDetailsCubit extends Cubit<ReservationDetailsState> {
  final ReservationApiService _api;
  final String reservationId;
  final ReservationHeader? initialHeader;

  ReservationDetailsCubit(
    this._api, {
    required this.reservationId,
    this.initialHeader,
  }) : super(ReservationDetailsState.initial()) {
    // seed header if provided (e.g., from Profile list)
    if (initialHeader != null) {
      emit(state.copyWith(header: initialHeader));
    }
  }

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final tickets = await _api.getTickets(reservationId);
      emit(state.copyWith(loading: false, tickets: tickets));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> refresh() => load();

  Future<void> cancel() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final ok = await _api.cancelReservation(reservationId);
      if (ok) {
        // flip header isCanceled and reload tickets
        final h = state.header;
        final updated = h == null
            ? null
            : ReservationHeader(
                reservationId: h.reservationId,
                isCanceled: true,
                totalPrice: h.totalPrice,
                ticketsCount: h.ticketsCount,
                startTime: h.startTime,
                hallName: h.hallName,
                cinemaName: h.cinemaName,
                movieTitle: h.movieTitle,
                posterUrl: h.posterUrl,
              );
        final tickets = await _api.getTickets(reservationId);
        emit(state.copyWith(loading: false, header: updated, tickets: tickets));
        // Notify any active seat maps to reload
        if (getIt.isRegistered<SeatMapRefreshBus>()) {
          getIt<SeatMapRefreshBus>().notify();
        }
        // Notify profile reservations lists to refresh
        if (getIt.isRegistered<ReservationsRefreshBus>()) {
          getIt<ReservationsRefreshBus>().notify();
        }
      } else {
        emit(state.copyWith(loading: false, error: 'Otkazivanje nije uspjelo.'));
      }
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
