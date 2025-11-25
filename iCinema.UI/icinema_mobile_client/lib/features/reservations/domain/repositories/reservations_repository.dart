import '../../data/models/seat_map.dart';
import '../../data/models/reservation_created.dart';
import '../../data/models/reservation_details_dto.dart';
import '../../data/models/ticket_dto.dart';
import '../../data/models/ticket_qr_dto.dart';

/// Repository interface for reservations feature operations
abstract class ReservationsRepository {
  /// Get seat map for a projection
  Future<SeatMapModel> getSeatMap(String projectionId);

  /// Create a new reservation
  Future<ReservationCreatedDto> createReservation({
    required String projectionId,
    required List<String> seatIds,
  });

  /// Cancel a reservation
  Future<bool> cancelReservation(String reservationId);

  /// Get reservation details
  Future<ReservationDetailsDto> getReservationDetails(String reservationId);

  /// Get tickets for a reservation
  Future<List<TicketDto>> getTickets(String reservationId);

  /// Get QR code for a ticket
  Future<TicketQrDto> getTicketQr(String ticketId);
}

