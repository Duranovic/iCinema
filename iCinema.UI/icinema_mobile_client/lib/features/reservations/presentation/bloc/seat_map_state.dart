import '../../data/models/seat_map.dart';

class SeatMapState {
  final bool loading;
  final String? error;
  final SeatMapModel? map;
  final Set<String> selectedSeatIds;
  final bool reserving;
  final String? successMessage;

  const SeatMapState({
    required this.loading,
    required this.error,
    required this.map,
    required this.selectedSeatIds,
    required this.reserving,
    required this.successMessage,
  });

  factory SeatMapState.initial() => const SeatMapState(
        loading: false,
        error: null,
        map: null,
        selectedSeatIds: {},
        reserving: false,
        successMessage: null,
      );

  double get totalPrice {
    final m = map;
    if (m == null) return 0;
    return (m.projection.price) * selectedSeatIds.length;
  }

  SeatMapState copyWith({
    bool? loading,
    String? error,
    bool clearError = false,
    SeatMapModel? map,
    Set<String>? selectedSeatIds,
    bool? reserving,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return SeatMapState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      map: map ?? this.map,
      selectedSeatIds: selectedSeatIds ?? this.selectedSeatIds,
      reserving: reserving ?? this.reserving,
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
