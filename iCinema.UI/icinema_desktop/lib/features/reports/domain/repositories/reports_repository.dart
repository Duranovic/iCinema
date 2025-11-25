import '../report_type.dart';
import '../../data/report_response_dto.dart';

abstract class ReportsRepository {
  Future<ReportResponseDto> generateReport({
    required ReportType reportType,
    required DateTime dateFrom,
    required DateTime dateTo,
  });
}

