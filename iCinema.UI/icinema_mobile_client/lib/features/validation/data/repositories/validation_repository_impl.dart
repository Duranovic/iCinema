import '../../domain/repositories/validation_repository.dart';
import '../datasources/validation_api_service.dart';
import '../models/validation_result.dart';

/// Implementation of ValidationRepository
class ValidationRepositoryImpl implements ValidationRepository {
  final ValidationApiService _apiService;

  ValidationRepositoryImpl(this._apiService);

  @override
  Future<ValidationResult> validateTicket(String qrCode) async {
    return await _apiService.validateTicket(qrCode);
  }
}

