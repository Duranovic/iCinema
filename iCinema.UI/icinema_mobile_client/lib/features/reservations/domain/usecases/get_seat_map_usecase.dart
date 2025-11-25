import '../../data/models/seat_map.dart';
import '../../data/models/reservation_created.dart';
import '../../data/models/reservation_details_dto.dart';
import '../../data/models/ticket_dto.dart';
import '../repositories/reservations_repository.dart';

/// Use case for getting seat map
class GetSeatMapUseCase {
  final ReservationsRepository _repository;

  GetSeatMapUseCase(this._repository);

  /// Execute getting seat map
  Future<SeatMapModel> call(String projectionId) async {
    return await _repository.getSeatMap(projectionId);
  }
}

/// Use case for creating reservation
class CreateReservationUseCase {
  final ReservationsRepository _repository;

  CreateReservationUseCase(this._repository);

  /// Execute creating reservation
  Future<ReservationCreatedDto> call({
    required String projectionId,
    required List<String> seatIds,
  }) async {
    return await _repository.createReservation(
      projectionId: projectionId,
      seatIds: seatIds,
    );
  }
}

/// Use case for canceling reservation
class CancelReservationUseCase {
  final ReservationsRepository _repository;

  CancelReservationUseCase(this._repository);

  /// Execute canceling reservation
  Future<bool> call(String reservationId) async {
    return await _repository.cancelReservation(reservationId);
  }
}

/// Use case for getting reservation details
class GetReservationDetailsUseCase {
  final ReservationsRepository _repository;

  GetReservationDetailsUseCase(this._repository);

  /// Execute getting reservation details
  Future<ReservationDetailsDto> call(String reservationId) async {
    return await _repository.getReservationDetails(reservationId);
  }
}

/// Use case for getting tickets
class GetTicketsUseCase {
  final ReservationsRepository _repository;

  GetTicketsUseCase(this._repository);

  /// Execute getting tickets
  Future<List<TicketDto>> call(String reservationId) async {
    return await _repository.getTickets(reservationId);
  }
}

