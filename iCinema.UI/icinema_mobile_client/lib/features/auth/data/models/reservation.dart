class ReservationModel {
  final String reservationId;
  final DateTime reservedAt;
  final bool isCanceled;
  final int ticketsCount;
  final String projectionId;
  final DateTime startTime;
  final String hallName;
  final String cinemaName;
  final String movieId;
  final String movieTitle;
  final String? posterUrl;

  const ReservationModel({
    required this.reservationId,
    required this.reservedAt,
    required this.isCanceled,
    required this.ticketsCount,
    required this.projectionId,
    required this.startTime,
    required this.hallName,
    required this.cinemaName,
    required this.movieId,
    required this.movieTitle,
    this.posterUrl,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      reservationId: (json['reservationId'] ?? '').toString(),
      reservedAt: DateTime.tryParse(json['reservedAt'] ?? '') ?? DateTime.now(),
      isCanceled: (json['isCanceled'] ?? false) as bool,
      ticketsCount: (json['ticketsCount'] ?? 0) as int,
      projectionId: (json['projectionId'] ?? '').toString(),
      startTime: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
      hallName: (json['hallName'] ?? '').toString(),
      cinemaName: (json['cinemaName'] ?? '').toString(),
      movieId: (json['movieId'] ?? '').toString(),
      movieTitle: (json['movieTitle'] ?? '').toString(),
      posterUrl: (json['posterUrl'] as String?)?.toString(),
    );
  }
}
