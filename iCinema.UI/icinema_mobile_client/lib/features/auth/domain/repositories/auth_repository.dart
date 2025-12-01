import 'package:icinema_shared/icinema_shared.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Login with email and password
  /// Returns a tuple of (token, expiresAt)
  Future<(String token, DateTime? expiresAt)> login({
    required String email,
    required String password,
  });

  /// Register a new user
  /// Returns a tuple of (token, expiresAt)
  Future<(String token, DateTime? expiresAt)> register({
    required String email,
    required String password,
    String? fullName,
  });

  /// Get current authenticated user information
  Future<UserMeModel> getMe();

  /// Get user's reservations with pagination
  Future<PagedResult<ReservationModel>> getMyReservationsPaged({
    required String status,
    int page = 1,
    int pageSize = 20,
  });

  /// Get user's reservations (non-paged)
  Future<List<ReservationModel>> getMyReservations({
    required String status,
    int page = 1,
    int pageSize = 20,
  });

  /// Get tickets for a reservation
  Future<List<TicketModel>> getReservationTickets(String reservationId);

  /// Update user profile
  Future<UserMeModel> updateProfile({
    required String fullName,
    String? currentPassword,
    String? newPassword,
  });
}



