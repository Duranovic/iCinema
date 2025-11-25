import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icinema_shared/icinema_shared.dart';
import '../../domain/usecases/get_my_reservations_usecase.dart';
import 'reservations_state.dart';

class ReservationsCubit extends Cubit<ReservationsState> {
  final GetMyReservationsPagedUseCase _getReservationsUseCase;
  final String status; // 'Active' | 'Past'

  ReservationsCubit(this._getReservationsUseCase, {required this.status})
      : super(ReservationsState.initial());

  Future<void> loadInitial({int pageSize = 20}) async {
    emit(state.copyWith(loading: true, page: 1, pageSize: pageSize, error: null));
    try {
      final paged = await _getReservationsUseCase(status: status, page: 1, pageSize: pageSize);
      emit(ReservationsState(
        items: paged.items,
        page: paged.page,
        pageSize: paged.pageSize,
        totalCount: paged.totalCount,
        loading: false,
        loadingMore: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore) return;
    emit(state.copyWith(loadingMore: true));
    try {
      final nextPage = state.page + 1;
      final paged = await _getReservationsUseCase(status: status, page: nextPage, pageSize: state.pageSize);
      emit(ReservationsState(
        items: [...state.items, ...paged.items],
        page: paged.page,
        pageSize: paged.pageSize,
        totalCount: paged.totalCount,
        loading: false,
        loadingMore: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(loadingMore: false, error: e.toString()));
    }
  }

  // Optimistic move of a canceled reservation.
  // If this cubit is for 'Active', remove it from the list.
  // If this cubit is for 'Past', prepend/update it as canceled.
  void markCanceledAndMove(String reservationId) {
    final items = List<ReservationModel>.from(state.items);
    final idx = items.indexWhere((r) => r.reservationId == reservationId);
    if (idx == -1) return;
    final r = items[idx];
    final updated = ReservationModel(
      reservationId: r.reservationId,
      reservedAt: r.reservedAt,
      isCanceled: true,
      ticketsCount: r.ticketsCount,
      projectionId: r.projectionId,
      startTime: r.startTime,
      hallName: r.hallName,
      cinemaName: r.cinemaName,
      movieId: r.movieId,
      movieTitle: r.movieTitle,
      posterUrl: r.posterUrl,
    );

    if (status == 'Active') {
      // Remove from active list
      items.removeAt(idx);
      // Keep counts consistent: reduce totalCount if needed
      final newTotal = state.totalCount > 0 ? state.totalCount - 1 : 0;
      emit(state.copyWith(items: items, totalCount: newTotal));
    } else {
      // Update in-place or insert at top for 'Past'
      items.removeAt(idx);
      items.insert(0, updated);
      emit(state.copyWith(items: items));
    }
  }
}
