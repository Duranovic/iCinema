class TicketModel {
  final String ticketId;
  final String? qrCode;
  final String ticketStatus; // Active, Used, Canceled
  final String? ticketType; // optional
  final int rowNumber;
  final int seatNumber;

  const TicketModel({
    required this.ticketId,
    this.qrCode,
    required this.ticketStatus,
    this.ticketType,
    required this.rowNumber,
    required this.seatNumber,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      ticketId: (json['ticketId'] ?? '').toString(),
      qrCode: json['qrCode'] as String?,
      ticketStatus: (json['ticketStatus'] ?? '').toString(),
      ticketType: (json['ticketType'] as String?),
      rowNumber: (json['rowNumber'] ?? 0) as int,
      seatNumber: (json['seatNumber'] ?? 0) as int,
    );
  }
}
