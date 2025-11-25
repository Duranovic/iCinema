import 'package:icinema_shared/icinema_shared.dart';
import '../repositories/auth_repository.dart';

/// Use case for getting user's reservations with pagination
class GetMyReservationsPagedUseCase {
  final AuthRepository _repository;

  GetMyReservationsPagedUseCase(this._repository);

  /// Execute getting reservations with pagination
  Future<PagedResult<ReservationModel>> call({
    required String status,
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _repository.getMyReservationsPaged(
      status: status,
      page: page,
      pageSize: pageSize,
    );
  }
}

/// Use case for getting user's reservations (non-paged)
class GetMyReservationsUseCase {
  final AuthRepository _repository;

  GetMyReservationsUseCase(this._repository);

  /// Execute getting reservations
  Future<List<ReservationModel>> call({
    required String status,
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _repository.getMyReservations(
      status: status,
      page: page,
      pageSize: pageSize,
    );
  }
}

