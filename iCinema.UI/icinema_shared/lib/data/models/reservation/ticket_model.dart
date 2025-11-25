/// Model representing a ticket
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

  /// Creates TicketModel from JSON
  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      ticketId: (json['ticketId'] ?? '').toString(),
      qrCode: json['qrCode'] as String?,
      ticketStatus: (json['ticketStatus'] ?? '').toString(),
      ticketType: json['ticketType'] as String?,
      rowNumber: (json['rowNumber'] ?? 0) as int,
      seatNumber: (json['seatNumber'] ?? 0) as int,
    );
  }

  /// Converts TicketModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      if (qrCode != null) 'qrCode': qrCode,
      'ticketStatus': ticketStatus,
      if (ticketType != null) 'ticketType': ticketType,
      'rowNumber': rowNumber,
      'seatNumber': seatNumber,
    };
  }

  /// Creates a copy with updated fields
  TicketModel copyWith({
    String? ticketId,
    String? qrCode,
    String? ticketStatus,
    String? ticketType,
    int? rowNumber,
    int? seatNumber,
  }) {
    return TicketModel(
      ticketId: ticketId ?? this.ticketId,
      qrCode: qrCode ?? this.qrCode,
      ticketStatus: ticketStatus ?? this.ticketStatus,
      ticketType: ticketType ?? this.ticketType,
      rowNumber: rowNumber ?? this.rowNumber,
      seatNumber: seatNumber ?? this.seatNumber,
    );
  }

  /// Checks if ticket is active
  bool get isActive => ticketStatus.toLowerCase() == 'active';

  /// Checks if ticket is used
  bool get isUsed => ticketStatus.toLowerCase() == 'used';

  /// Checks if ticket is canceled
  bool get isCanceled => ticketStatus.toLowerCase() == 'canceled';

  @override
  String toString() => 'TicketModel(ticketId: $ticketId, status: $ticketStatus, seat: Row $rowNumber, Seat $seatNumber)';
}

