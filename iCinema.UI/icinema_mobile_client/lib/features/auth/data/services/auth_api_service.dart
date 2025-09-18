import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/user_me.dart';
import '../models/reservation.dart';
import '../models/ticket.dart';
import '../../../../app/models/paged_result.dart';

class AuthApiService {
  final Dio _dio;
  AuthApiService(this._dio);

  Future<(String token, DateTime? expiresAt)> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
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
      final status = e.response?.statusCode;
      if (status == 401) {
        throw Exception('Neispravni kredencijali.');
      }
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
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Nema konekcije sa serverom.');
      }
      if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Vrijeme za odgovor je isteklo.');
      }
      if (e.type == DioExceptionType.badCertificate) {
        throw Exception('SSL greška (certifikat).');
      }
      throw Exception('Greška (${status ?? 'nepoznata'}). Pokušajte ponovo.');
    }
  }

  Future<UserMe> getMe() async {
    try {
      final response = await _dio.get('/users/me');
      final data = response.data;
      Map<String, dynamic> map;
      if (data is String) {
        map = json.decode(data) as Map<String, dynamic>;
      } else {
        map = data as Map<String, dynamic>;
      }
      return UserMe.fromJson(map);
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

  Future<(String token, DateTime? expiresAt)> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _dio.post(
        '/Auth/register',
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

  Future<PagedResult<ReservationModel>> getMyReservationsPaged({
    required String status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await _dio.get(
      '/users/me/reservations',
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

  Future<List<ReservationModel>> getMyReservations({
    required String status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final paged = await getMyReservationsPaged(status: status, page: page, pageSize: pageSize);
    return paged.items;
  }

  Future<List<TicketModel>> getReservationTickets(String reservationId) async {
    final resp = await _dio.get('/users/me/reservations/$reservationId/tickets');
    final data = resp.data;
    final list = data is String ? (json.decode(data) as List) : (data as List);
    return list.map((e) => TicketModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
