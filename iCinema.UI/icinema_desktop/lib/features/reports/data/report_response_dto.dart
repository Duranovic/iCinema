class ReportResponseDto {
  final int reportType;
  final ReportPeriodDto period;
  final List<Map<String, dynamic>> data;

  ReportResponseDto({
    required this.reportType,
    required this.period,
    required this.data,
  });

  factory ReportResponseDto.fromJson(Map<String, dynamic> json) {
    return ReportResponseDto(
      reportType: json['reportType'] as int,
      period: ReportPeriodDto.fromJson(json['period'] as Map<String, dynamic>),
      data: (json['data'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList(),
    );
  }
}

class ReportPeriodDto {
  final DateTime from;
  final DateTime to;

  ReportPeriodDto({
    required this.from,
    required this.to,
  });

  factory ReportPeriodDto.fromJson(Map<String, dynamic> json) {
    return ReportPeriodDto(
      from: DateTime.parse(json['from'] as String),
      to: DateTime.parse(json['to'] as String),
    );
  }
}
