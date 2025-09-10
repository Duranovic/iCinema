import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../domain/report_type.dart';
import 'report_request_dto.dart';
import 'report_response_dto.dart';

@lazySingleton
class ReportsService {
  final Dio _dio;
  
  ReportsService(this._dio);

  Future<ReportResponseDto> generateReport({
    required ReportType reportType,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    final request = ReportRequestDto(
      reportTypeEnum: reportType,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );

    final response = await _dio.post(
      '/reports/generate',
      data: request.toJson(),
    );

    return ReportResponseDto.fromJson(response.data);
  }
}
