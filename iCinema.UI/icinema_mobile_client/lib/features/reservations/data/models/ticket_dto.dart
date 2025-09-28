class TicketDto {
  final String ticketId;
  final String? qrCode;
  final String ticketStatus; // Active | Used | Canceled
  final String? ticketType;
  final int rowNumber;
  final int seatNumber;

  const TicketDto({
    required this.ticketId,
    required this.qrCode,
    required this.ticketStatus,
    required this.ticketType,
    required this.rowNumber,
    required this.seatNumber,
  });

  factory TicketDto.fromJson(Map<String, dynamic> json) => TicketDto(
        ticketId: json['ticketId']?.toString() ?? '',
        qrCode: json['qrCode'] as String?,
        ticketStatus: json['ticketStatus']?.toString() ?? 'Active',
        ticketType: json['ticketType'] as String?,
        rowNumber: (json['rowNumber'] as num?)?.toInt() ?? 0,
        seatNumber: (json['seatNumber'] as num?)?.toInt() ?? 0,
      );
}
