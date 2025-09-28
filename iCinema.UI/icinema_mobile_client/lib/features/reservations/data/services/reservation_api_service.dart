import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/seat_map.dart';
import '../models/reservation_created.dart';
import '../models/ticket_dto.dart';
import '../models/reservation_details_dto.dart';
import '../models/ticket_qr_dto.dart';

class ReservationApiService {
  final Dio _dio;
  ReservationApiService(this._dio);

  Future<SeatMapModel> getSeatMap(String projectionId) async {
    try {
      final resp = await _dio.get('/projections/$projectionId/seat-map');
      final data = resp.data is String ? json.decode(resp.data as String) : resp.data;
      return SeatMapModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404) {
        throw Exception('Projekcija nije pronađena.');
      }
      throw Exception('Ne mogu učitati mapu sjedišta (${status ?? 'nepoznato'}).');
    }
  }

  Future<ReservationCreatedDto> createReservation({
    required String projectionId,
    required List<String> seatIds,
  }) async {
    try {
      final resp = await _dio.post('/reservations', data: {
        'projectionId': projectionId,
        'seatIds': seatIds,
      });
      final data = resp.data is String ? json.decode(resp.data as String) : resp.data;
      return ReservationCreatedDto.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 400) throw Exception('Neispravan odabir sjedala.');
      if (status == 401) throw Exception('Morate biti prijavljeni.');
      if (status == 404) throw Exception('Projekcija nije pronađena.');
      if (status == 409) throw Exception('Neko je upravo zauzeo odabrano mjesto. Pokušajte ponovo.');
      throw Exception('Greška pri rezervaciji (${status ?? 'nepoznato'}).');
    }
  }

  Future<bool> cancelReservation(String reservationId) async {
    try {
      final resp = await _dio.post('/reservations/$reservationId/cancel');
      if (resp.data is Map && (resp.data['success'] == true)) return true;
      return resp.statusCode == 200;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) throw Exception('Morate biti prijavljeni.');
      if (status == 404) throw Exception('Rezervacija nije pronađena.');
      throw Exception('Greška pri otkazivanju (${status ?? 'nepoznato'}).');
    }
  }

  Future<ReservationDetailsDto> getReservationDetails(String reservationId) async {
    try {
      final resp = await _dio.get('/reservations/$reservationId');
      final data = resp.data is String ? json.decode(resp.data as String) : resp.data;
      return ReservationDetailsDto.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) throw Exception('Morate biti prijavljeni.');
      if (status == 404) throw Exception('Rezervacija nije pronađena.');
      throw Exception('Ne mogu učitati detalje rezervacije (${status ?? 'nepoznato'}).');
    }
  }

  Future<List<TicketDto>> getTickets(String reservationId) async {
    try {
      final resp = await _dio.get('/users/me/reservations/$reservationId/tickets');
      final data = resp.data is String ? json.decode(resp.data as String) : resp.data;
      final list = (data as List).cast<dynamic>();
      return list.map((e) => TicketDto.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) throw Exception('Morate biti prijavljeni.');
      if (status == 404) throw Exception('Karte nisu pronađene.');
      throw Exception('Ne mogu učitati karte (${status ?? 'nepoznato'}).');
    }
  }

  Future<TicketQrDto> getTicketQr(String ticketId) async {
    try {
      final resp = await _dio.get('/tickets/$ticketId/qr');
      final data = resp.data is String ? json.decode(resp.data as String) : resp.data;
      return TicketQrDto.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) throw Exception('Morate biti prijavljeni.');
      if (status == 404) throw Exception('Karta nije pronađena.');
      throw Exception('Ne mogu učitati QR informacije (${status ?? 'nepoznato'}).');
    }
  }
}
