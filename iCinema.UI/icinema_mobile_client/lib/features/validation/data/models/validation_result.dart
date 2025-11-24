enum ValidationStatus {
  valid,
  used,
  invalid,
  expired,
}

class ValidationResult {
  final ValidationStatus status;
  final String message;
  final TicketInfo? ticketInfo;

  const ValidationResult({
    required this.status,
    required this.message,
    this.ticketInfo,
  });

  factory ValidationResult.fromJson(Map<String, dynamic> json) {
    ValidationStatus status;
    final statusStr = (json['status'] ?? '').toString().toLowerCase();
    
    switch (statusStr) {
      case 'valid':
        status = ValidationStatus.valid;
        break;
      case 'used':
      case 'iskorištena':
        status = ValidationStatus.used;
        break;
      case 'expired':
      case 'nevažeća':
        status = ValidationStatus.expired;
        break;
      default:
        status = ValidationStatus.invalid;
    }

    return ValidationResult(
      status: status,
      message: (json['message'] ?? '').toString(),
      ticketInfo: json['ticketInfo'] != null
          ? TicketInfo.fromJson(json['ticketInfo'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TicketInfo {
  final String movieTitle;
  final String cinemaName;
  final String hallName;
  final DateTime startTime;
  final String seatNumber;
  final double price;

  const TicketInfo({
    required this.movieTitle,
    required this.cinemaName,
    required this.hallName,
    required this.startTime,
    required this.seatNumber,
    required this.price,
  });

  factory TicketInfo.fromJson(Map<String, dynamic> json) {
    return TicketInfo(
      movieTitle: (json['movieTitle'] ?? 'N/A').toString(),
      cinemaName: (json['cinemaName'] ?? 'N/A').toString(),
      hallName: (json['hallName'] ?? 'N/A').toString(),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'].toString())
          : DateTime.now(),
      seatNumber: (json['seatNumber'] ?? 'N/A').toString(),
      price: (json['price'] ?? 0.0) is int
          ? (json['price'] as int).toDouble()
          : (json['price'] ?? 0.0) as double,
    );
  }
}
