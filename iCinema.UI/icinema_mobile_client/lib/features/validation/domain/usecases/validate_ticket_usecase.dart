import '../../data/models/validation_result.dart';
import '../repositories/validation_repository.dart';

/// Use case for validating a ticket
class ValidateTicketUseCase {
  final ValidationRepository _repository;

  ValidateTicketUseCase(this._repository);

  /// Execute ticket validation
  Future<ValidationResult> call(String qrCode) async {
    return await _repository.validateTicket(qrCode);
  }
}

