import '../../data/models/ticket_qr_dto.dart';
import '../repositories/reservations_repository.dart';

/// Use case for getting ticket QR code
class GetTicketQrUseCase {
  final ReservationsRepository _repository;

  GetTicketQrUseCase(this._repository);

  /// Execute getting ticket QR
  Future<TicketQrDto> call(String ticketId) async {
    return await _repository.getTicketQr(ticketId);
  }
}

