class ReservationDetailsDto {
  final String reservationId;
  final bool isCanceled;
  final double totalPrice;
  final int ticketsCount;
  final ProjectionDetails projection;
  final List<SeatBrief> seats;

  const ReservationDetailsDto({
    required this.reservationId,
    required this.isCanceled,
    required this.totalPrice,
    required this.ticketsCount,
    required this.projection,
    required this.seats,
  });

  factory ReservationDetailsDto.fromJson(Map<String, dynamic> json) {
    return ReservationDetailsDto(
      reservationId: (json['reservationId'] ?? '').toString(),
      isCanceled: (json['isCanceled'] as bool?) ?? false,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      ticketsCount: (json['ticketsCount'] as num?)?.toInt() ?? 0,
      projection: ProjectionDetails.fromJson(json['projection'] as Map<String, dynamic>),
      seats: ((json['seats'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SeatBrief.fromJson)
          .toList(),
    );
  }
}

class ProjectionDetails {
  final String id;
  final DateTime startTime;
  final double price;
  final String hallName;
  final String cinemaName;
  final String movieId;
  final String movieTitle;
  final String? posterUrl;

  const ProjectionDetails({
    required this.id,
    required this.startTime,
    required this.price,
    required this.hallName,
    required this.cinemaName,
    required this.movieId,
    required this.movieTitle,
    required this.posterUrl,
  });

  factory ProjectionDetails.fromJson(Map<String, dynamic> json) {
    return ProjectionDetails(
      id: (json['id'] ?? '').toString(),
      startTime: DateTime.tryParse((json['startTime']).toString()) ?? DateTime.now(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      hallName: (json['hallName'] ?? '').toString(),
      cinemaName: (json['cinemaName'] ?? '').toString(),
      movieId: (json['movieId'] ?? '').toString(),
      movieTitle: (json['movieTitle'] ?? '').toString(),
      posterUrl: json['posterUrl'] as String?,
    );
  }
}

class SeatBrief {
  final String seatId;
  final int rowNumber;
  final int seatNumber;

  const SeatBrief({required this.seatId, required this.rowNumber, required this.seatNumber});

  factory SeatBrief.fromJson(Map<String, dynamic> json) => SeatBrief(
        seatId: (json['seatId'] ?? '').toString(),
        rowNumber: (json['rowNumber'] as num?)?.toInt() ?? 0,
        seatNumber: (json['seatNumber'] as num?)?.toInt() ?? 0,
      );
}
