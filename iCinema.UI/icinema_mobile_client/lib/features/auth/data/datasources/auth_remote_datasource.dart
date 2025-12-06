import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:icinema_shared/icinema_shared.dart';

/// Remote data source for authentication API calls
abstract class AuthRemoteDataSource {
  Future<(String token, DateTime? expiresAt)> login({
    required String email,
    required String password,
  });

  Future<(String token, DateTime? expiresAt)> register({
    required String email,
    required String password,
    String? fullName,
  });

  Future<UserMeModel> getMe();

  Future<PagedResult<ReservationModel>> getMyReservationsPaged({
    required String status,
    int page = 1,
    int pageSize = 20,
  });

  Future<List<ReservationModel>> getMyReservations({
    required String status,
    int page = 1,
    int pageSize = 20,
  });

  Future<List<TicketModel>> getReservationTickets(String reservationId);

  Future<UserMeModel> updateProfile({
    required String fullName,
    String? currentPassword,
    String? newPassword,
  });
}

/// Implementation of AuthRemoteDataSource
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<(String token, DateTime? expiresAt)> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      final expiresAtRaw = data['expiresAt'] as String?;
      if (token == null || token.isEmpty) {
        throw DioException(
          requestOptions: response.requestOptions,
          error: 'Prazan token u odgovoru',
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
      final expiresAt = expiresAtRaw != null ? DateTime.tryParse(expiresAtRaw) : null;
      return (token, expiresAt);
    } on DioException catch (e) {
      // Let ErrorHandler extract the message from DioException
      // It will check response.data first (which contains "Nevažeći podaci za prijavu.")
      // before falling back to default messages
      rethrow;
    }
  }

  @override
  Future<UserMeModel> getMe() async {
    try {
      final response = await _dio.get(ApiEndpoints.usersMe);
      final data = response.data;
      Map<String, dynamic> map;
      if (data is String) {
        map = json.decode(data) as Map<String, dynamic>;
      } else {
        map = data as Map<String, dynamic>;
      }
      return UserMeModel.fromJson(map);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      if (body is String && body.isNotEmpty) {
        throw Exception(body);
      }
      if (body is Map) {
        final msg = body['message'] ?? body['error'] ?? body['title'];
        if (msg is String && msg.isNotEmpty) {
          throw Exception(msg);
        }
      }
      throw Exception('Ne mogu učitati podatke o korisniku (${status ?? 'nepoznato'}).');
    }
  }

  @override
  Future<(String token, DateTime? expiresAt)> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          if (fullName != null && fullName.isNotEmpty) 'fullName': fullName,
        },
      );
      final data = response.data;
      Map<String, dynamic> map;
      if (data is String) {
        map = json.decode(data) as Map<String, dynamic>;
      } else {
        map = data as Map<String, dynamic>;
      }
      final token = map['token'] as String?;
      final expiresAtRaw = map['expiresAt'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('Nevažeći odgovor sa servera.');
      }
      final expiresAt = expiresAtRaw != null ? DateTime.tryParse(expiresAtRaw) : null;
      return (token, expiresAt);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      if (status == 409) {
        throw Exception('Korisnik sa ovim emailom već postoji.');
      }
      if (body is String && body.isNotEmpty) throw Exception(body);
      if (body is Map) {
        final msg = body['message'] ?? body['error'] ?? body['title'];
        if (msg is String && msg.isNotEmpty) throw Exception(msg);
      }
      throw Exception('Greška pri registraciji (${status ?? 'nepoznata'}).');
    }
  }

  @override
  Future<PagedResult<ReservationModel>> getMyReservationsPaged({
    required String status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await _dio.get(
      ApiEndpoints.usersMeReservations,
      queryParameters: {
        'status': status,
        'page': page,
        'pageSize': pageSize,
      },
    );
    final data = resp.data is String ? json.decode(resp.data as String) : resp.data;
    if (data is Map<String, dynamic>) {
      final items = ((data['items'] as List?) ?? const [])
          .map((e) => ReservationModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final total = (data['totalCount'] ?? items.length) as int;
      final pg = (data['page'] ?? page) as int;
      final ps = (data['pageSize'] ?? pageSize) as int;
      return PagedResult(items: items, totalCount: total, page: pg, pageSize: ps);
    }
    // Fallback: API returned a plain list
    final list = (data as List)
        .map((e) => ReservationModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return PagedResult(items: list, totalCount: list.length, page: page, pageSize: pageSize);
  }

  @override
  Future<List<ReservationModel>> getMyReservations({
    required String status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final paged = await getMyReservationsPaged(status: status, page: page, pageSize: pageSize);
    return paged.items;
  }

  @override
  Future<List<TicketModel>> getReservationTickets(String reservationId) async {
    final resp = await _dio.get(ApiEndpoints.reservationTickets(reservationId));
    final data = resp.data;
    final list = data is String ? (json.decode(data) as List) : (data as List);
    return list.map((e) => TicketModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<UserMeModel> updateProfile({
    required String fullName,
    String? currentPassword,
    String? newPassword,
  }) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.usersMe,
        data: {
          'fullName': fullName,
          if (currentPassword != null && currentPassword.isNotEmpty)
            'currentPassword': currentPassword,
          if (newPassword != null && newPassword.isNotEmpty)
            'newPassword': newPassword,
        },
      );
      final data = response.data;
      Map<String, dynamic> map;
      if (data is String) {
        map = json.decode(data) as Map<String, dynamic>;
      } else {
        map = data as Map<String, dynamic>;
      }
      return UserMeModel.fromJson(map);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      
      if (status == 400) {
        if (body is Map) {
          final msg = body['message'] ?? body['error'] ?? body['title'];
          if (msg is String && msg.isNotEmpty) {
            throw Exception(msg);
          }
        }
        throw Exception('Neispravni podaci. Provjerite unos.');
      }
      
      if (status == 401) {
        throw Exception('Trenutna lozinka nije ispravna.');
      }
      
      if (body is String && body.isNotEmpty) {
        throw Exception(body);
      }
      
      if (body is Map) {
        final msg = body['message'] ?? body['error'] ?? body['title'];
        if (msg is String && msg.isNotEmpty) {
          throw Exception(msg);
        }
      }
      
      throw Exception('Greška pri ažuriranju profila (${status ?? 'nepoznata'}).');
    }
  }
}



