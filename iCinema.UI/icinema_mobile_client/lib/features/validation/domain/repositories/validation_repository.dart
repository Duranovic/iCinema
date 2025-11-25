import '../../data/models/validation_result.dart';

/// Repository interface for validation feature operations
abstract class ValidationRepository {
  /// Validate a ticket by QR code
  Future<ValidationResult> validateTicket(String qrCode);
}

