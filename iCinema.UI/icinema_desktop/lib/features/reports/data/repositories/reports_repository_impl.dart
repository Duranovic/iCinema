import 'package:injectable/injectable.dart';
import '../../domain/report_type.dart';
import '../../domain/repositories/reports_repository.dart';
import '../report_response_dto.dart';
import '../reports_service.dart';

@LazySingleton(as: ReportsRepository)
class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsService _service;

  ReportsRepositoryImpl(this._service);

  @override
  Future<ReportResponseDto> generateReport({
    required ReportType reportType,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) =>
      _service.generateReport(
        reportType: reportType,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
}

