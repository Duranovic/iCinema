import '../domain/report_type.dart';

class ReportRequestDto {
  final int reportType;
  final DateTime dateFrom;
  final DateTime dateTo;

  ReportRequestDto({
    required ReportType reportTypeEnum,
    required this.dateFrom,
    required this.dateTo,
  }) : reportType = reportTypeEnum.index;

  Map<String, dynamic> toJson() {
    return {
      'reportType': reportType,
      'dateFrom': dateFrom.toIso8601String(),
      'dateTo': dateTo.toIso8601String(),
    };
  }
}
