class TicketQrDto {
  final String token;
  final DateTime? expiresAt;

  const TicketQrDto({required this.token, required this.expiresAt});

  factory TicketQrDto.fromJson(Map<String, dynamic> json) => TicketQrDto(
        token: (json['token'] ?? '').toString(),
        expiresAt: json['expiresAt'] == null
            ? null
            : DateTime.tryParse(json['expiresAt'].toString()),
      );
}
