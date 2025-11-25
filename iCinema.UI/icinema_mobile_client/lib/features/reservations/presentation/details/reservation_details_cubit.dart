import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_seat_map_usecase.dart';
import 'reservation_details_state.dart';
import '../../data/seat_map_refresh_bus.dart';
import '../../../../app/di/injection.dart';
import '../../../auth/data/reservations_refresh_bus.dart';

class ReservationDetailsCubit extends Cubit<ReservationDetailsState> {
  final GetTicketsUseCase _getTicketsUseCase;
  final CancelReservationUseCase _cancelReservationUseCase;
  final String reservationId;
  final ReservationHeader? initialHeader;

  ReservationDetailsCubit(
    this._getTicketsUseCase,
    this._cancelReservationUseCase, {
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
      final tickets = await _getTicketsUseCase(reservationId);
      emit(state.copyWith(loading: false, tickets: tickets));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> refresh() => load();

  Future<void> cancel() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final ok = await _cancelReservationUseCase(reservationId);
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
        final tickets = await _getTicketsUseCase(reservationId);
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
