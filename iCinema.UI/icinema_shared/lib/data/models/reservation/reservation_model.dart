/// Model representing a reservation
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

  /// Creates ReservationModel from JSON
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

  /// Converts ReservationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'reservationId': reservationId,
      'reservedAt': reservedAt.toIso8601String(),
      'isCanceled': isCanceled,
      'ticketsCount': ticketsCount,
      'projectionId': projectionId,
      'startTime': startTime.toIso8601String(),
      'hallName': hallName,
      'cinemaName': cinemaName,
      'movieId': movieId,
      'movieTitle': movieTitle,
      if (posterUrl != null) 'posterUrl': posterUrl,
    };
  }

  /// Creates a copy with updated fields
  ReservationModel copyWith({
    String? reservationId,
    DateTime? reservedAt,
    bool? isCanceled,
    int? ticketsCount,
    String? projectionId,
    DateTime? startTime,
    String? hallName,
    String? cinemaName,
    String? movieId,
    String? movieTitle,
    String? posterUrl,
  }) {
    return ReservationModel(
      reservationId: reservationId ?? this.reservationId,
      reservedAt: reservedAt ?? this.reservedAt,
      isCanceled: isCanceled ?? this.isCanceled,
      ticketsCount: ticketsCount ?? this.ticketsCount,
      projectionId: projectionId ?? this.projectionId,
      startTime: startTime ?? this.startTime,
      hallName: hallName ?? this.hallName,
      cinemaName: cinemaName ?? this.cinemaName,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      posterUrl: posterUrl ?? this.posterUrl,
    );
  }

  @override
  String toString() => 'ReservationModel(reservationId: $reservationId, movieTitle: $movieTitle, startTime: $startTime)';
}

