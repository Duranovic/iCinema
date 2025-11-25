import 'package:icinema_shared/icinema_shared.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<(String token, DateTime? expiresAt)> login({
    required String email,
    required String password,
  }) async {
    return await _remoteDataSource.login(email: email, password: password);
  }

  @override
  Future<(String token, DateTime? expiresAt)> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return await _remoteDataSource.register(
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  @override
  Future<UserMeModel> getMe() async {
    return await _remoteDataSource.getMe();
  }

  @override
  Future<PagedResult<ReservationModel>> getMyReservationsPaged({
    required String status,
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _remoteDataSource.getMyReservationsPaged(
      status: status,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<List<ReservationModel>> getMyReservations({
    required String status,
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _remoteDataSource.getMyReservations(
      status: status,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<List<TicketModel>> getReservationTickets(String reservationId) async {
    return await _remoteDataSource.getReservationTickets(reservationId);
  }

  @override
  Future<UserMeModel> updateProfile({
    required String fullName,
    String? currentPassword,
    String? newPassword,
  }) async {
    return await _remoteDataSource.updateProfile(
      fullName: fullName,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}

