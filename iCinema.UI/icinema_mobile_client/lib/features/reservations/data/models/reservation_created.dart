class ReservationCreatedDto {
  final String reservationId;
  final int ticketsCount;
  final DateTime? expiresAt;
  final double totalPrice;

  const ReservationCreatedDto({
    required this.reservationId,
    required this.ticketsCount,
    required this.expiresAt,
    required this.totalPrice,
  });

  factory ReservationCreatedDto.fromJson(Map<String, dynamic> json) {
    return ReservationCreatedDto(
      reservationId: (json['reservationId'] ?? '').toString(),
      ticketsCount: (json['ticketsCount'] ?? 0) as int,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.tryParse((json['expiresAt']).toString()),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
