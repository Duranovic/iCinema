import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:icinema_shared/icinema_shared.dart';
import '../models/validation_result.dart';

class ValidationApiService {
  final Dio _dio;

  ValidationApiService(this._dio);

  /// Validates a ticket by QR code content
  Future<ValidationResult> validateTicket(String qrCode) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.ticketsValidate,
        data: {'token': qrCode},
      );

      final data = response.data;
      Map<String, dynamic> map;
      if (data is String) {
        map = json.decode(data) as Map<String, dynamic>;
      } else {
        map = data as Map<String, dynamic>;
      }

      return ValidationResult.fromJson(map);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;

      if (status == 401) {
        return const ValidationResult(
          status: ValidationStatus.invalid,
          message: 'Nemate dozvolu za validaciju. Molimo prijavite se.',
        );
      }

      if (status == 404) {
        return const ValidationResult(
          status: ValidationStatus.invalid,
          message: 'Karta nije pronađena.',
        );
      }

      if (status == 400) {
        if (body is Map) {
          final msg = body['message'] ?? body['error'] ?? body['title'];
          if (msg is String && msg.isNotEmpty) {
            return ValidationResult(
              status: ValidationStatus.invalid,
              message: msg,
            );
          }
        }
        return const ValidationResult(
          status: ValidationStatus.invalid,
          message: 'Nevažeći QR kod.',
        );
      }

      if (body is String && body.isNotEmpty) {
        return ValidationResult(
          status: ValidationStatus.invalid,
          message: body,
        );
      }

      if (body is Map) {
        final msg = body['message'] ?? body['error'] ?? body['title'];
        if (msg is String && msg.isNotEmpty) {
          return ValidationResult(
            status: ValidationStatus.invalid,
            message: msg,
          );
        }
      }

      return ValidationResult(
        status: ValidationStatus.invalid,
        message: 'Greška pri validaciji (${status ?? 'nepoznata'}).',
      );
    }
  }
}
