import 'package:injectable/injectable.dart';
import '../report_type.dart';
import '../repositories/reports_repository.dart';
import '../../data/report_response_dto.dart';

@lazySingleton
class GenerateReportUseCase {
  final ReportsRepository _repository;

  GenerateReportUseCase(this._repository);

  Future<ReportResponseDto> call({
    required ReportType reportType,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) {
    return _repository.generateReport(
      reportType: reportType,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }
}



