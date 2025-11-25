import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/validate_ticket_usecase.dart';
import '../../data/models/validation_result.dart';

// States
abstract class ValidationState {}

class ValidationInitial extends ValidationState {}

class ValidationScanning extends ValidationState {}

class ValidationLoading extends ValidationState {
  final String qrCode;
  ValidationLoading(this.qrCode);
}

class ValidationSuccess extends ValidationState {
  final ValidationResult result;
  ValidationSuccess(this.result);
}

class ValidationError extends ValidationState {
  final String message;
  ValidationError(this.message);
}

// Cubit
class ValidationCubit extends Cubit<ValidationState> {
  final ValidateTicketUseCase _validateTicketUseCase;

  ValidationCubit(this._validateTicketUseCase) : super(ValidationInitial());

  void startScanning() {
    emit(ValidationScanning());
  }

  void reset() {
    emit(ValidationInitial());
  }

  Future<void> validateTicket(String qrCode) async {
    if (qrCode.isEmpty) {
      emit(ValidationError('QR kod je prazan.'));
      return;
    }

    emit(ValidationLoading(qrCode));

    try {
      final result = await _validateTicketUseCase(qrCode);
      emit(ValidationSuccess(result));
    } catch (e) {
      emit(ValidationError('Greška pri validaciji: ${e.toString()}'));
    }
  }
}
