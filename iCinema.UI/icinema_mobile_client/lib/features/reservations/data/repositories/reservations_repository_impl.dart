import '../../domain/repositories/reservations_repository.dart';
import '../datasources/reservation_api_service.dart';
import '../models/seat_map.dart';
import '../models/reservation_created.dart';
import '../models/reservation_details_dto.dart';
import '../models/ticket_dto.dart';
import '../models/ticket_qr_dto.dart';

/// Implementation of ReservationsRepository
class ReservationsRepositoryImpl implements ReservationsRepository {
  final ReservationApiService _apiService;

  ReservationsRepositoryImpl(this._apiService);

  @override
  Future<SeatMapModel> getSeatMap(String projectionId) async {
    return await _apiService.getSeatMap(projectionId);
  }

  @override
  Future<ReservationCreatedDto> createReservation({
    required String projectionId,
    required List<String> seatIds,
  }) async {
    return await _apiService.createReservation(
      projectionId: projectionId,
      seatIds: seatIds,
    );
  }

  @override
  Future<bool> cancelReservation(String reservationId) async {
    return await _apiService.cancelReservation(reservationId);
  }

  @override
  Future<ReservationDetailsDto> getReservationDetails(String reservationId) async {
    return await _apiService.getReservationDetails(reservationId);
  }

  @override
  Future<List<TicketDto>> getTickets(String reservationId) async {
    return await _apiService.getTickets(reservationId);
  }

  @override
  Future<TicketQrDto> getTicketQr(String ticketId) async {
    return await _apiService.getTicketQr(ticketId);
  }
}

