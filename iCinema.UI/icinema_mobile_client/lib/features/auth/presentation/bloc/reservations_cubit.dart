import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/auth_api_service.dart';
import 'reservations_state.dart';

class ReservationsCubit extends Cubit<ReservationsState> {
  final AuthApiService _api;
  final String status; // 'Active' | 'Past'

  ReservationsCubit(this._api, {required this.status})
      : super(ReservationsState.initial());

  Future<void> loadInitial({int pageSize = 20}) async {
    emit(state.copyWith(loading: true, page: 1, pageSize: pageSize, error: null));
    try {
      final paged = await _api.getMyReservationsPaged(status: status, page: 1, pageSize: pageSize);
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
      final paged = await _api.getMyReservationsPaged(status: status, page: nextPage, pageSize: state.pageSize);
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
}
