import '../../data/models/ticket_dto.dart';

class ReservationDetailsState {
  final bool loading;
  final String? error;
  final ReservationHeader? header;
  final List<TicketDto> tickets;

  const ReservationDetailsState({
    required this.loading,
    required this.error,
    required this.header,
    required this.tickets,
  });

  factory ReservationDetailsState.initial() => const ReservationDetailsState(
        loading: true,
        error: null,
        header: null,
        tickets: [],
      );

  ReservationDetailsState copyWith({
    bool? loading,
    String? error,
    bool clearError = false,
    ReservationHeader? header,
    List<TicketDto>? tickets,
  }) => ReservationDetailsState(
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
        header: header ?? this.header,
        tickets: tickets ?? this.tickets,
      );
}

class ReservationHeader {
  final String reservationId;
  final bool isCanceled;
  final double? totalPrice;
  final int? ticketsCount;
  final DateTime? startTime;
  final String? hallName;
  final String? cinemaName;
  final String? movieTitle;
  final String? posterUrl;

  const ReservationHeader({
    required this.reservationId,
    required this.isCanceled,
    this.totalPrice,
    this.ticketsCount,
    this.startTime,
    this.hallName,
    this.cinemaName,
    this.movieTitle,
    this.posterUrl,
  });
}
