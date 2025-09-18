import '../../data/models/reservation.dart';

class ReservationsState {
  final List<ReservationModel> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final bool loading;
  final bool loadingMore;
  final String? error;

  const ReservationsState({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.loading,
    required this.loadingMore,
    this.error,
  });

  factory ReservationsState.initial() => const ReservationsState(
        items: [],
        page: 1,
        pageSize: 20,
        totalCount: 0,
        loading: false,
        loadingMore: false,
      );

  bool get hasMore => items.length < totalCount;

  ReservationsState copyWith({
    List<ReservationModel>? items,
    int? page,
    int? pageSize,
    int? totalCount,
    bool? loading,
    bool? loadingMore,
    String? error,
  }) {
    return ReservationsState(
      items: items ?? this.items,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: error,
    );
  }
}
