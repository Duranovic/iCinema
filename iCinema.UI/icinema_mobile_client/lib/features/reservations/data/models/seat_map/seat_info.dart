class SeatInfo {
  final String seatId;
  final int rowNumber;
  final int seatNumber;
  final bool isTaken;

  const SeatInfo({
    required this.seatId,
    required this.rowNumber,
    required this.seatNumber,
    required this.isTaken,
  });

  factory SeatInfo.fromJson(Map<String, dynamic> json) {
    return SeatInfo(
      seatId: (json['seatId'] ?? '').toString(),
      rowNumber: (json['rowNumber'] ?? 0) as int,
      seatNumber: (json['seatNumber'] ?? 0) as int,
      isTaken: (json['isTaken'] ?? false) as bool,
    );
  }
}
