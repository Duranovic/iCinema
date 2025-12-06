import 'package:dio/dio.dart';
import 'package:icinema_desktop/features/projections/domain/cinema.dart';
import 'package:icinema_desktop/features/projections/domain/hall.dart';
import 'package:icinema_shared/icinema_shared.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CinemaService {
  final Dio _dio;
  CinemaService(this._dio);

  Future<List<Cinema>> fetchCinemas() async {
    final res = await _dio.get(ApiEndpoints.cinemas);
    final items = res.data['items'] as List<dynamic>;
    return items.map((e) => Cinema.fromJson(e)).toList();
  }

  Future<Cinema> createCinema(Cinema cinema) async {
    final payload = {
      'name': cinema.name,
      'address': cinema.address,
      'email': cinema.email,
      'phoneNumber': cinema.phoneNumber,
      'cityId': cinema.cityId,
    };
    
    final res = await _dio.post(ApiEndpoints.cinemas, data: payload);
    return Cinema.fromJson(res.data);
  }

  Future<Cinema> updateCinema(Cinema cinema) async {
    final payload = {
      'name': cinema.name,
      'address': cinema.address,
      'email': cinema.email,
      'phoneNumber': cinema.phoneNumber,
      'cityId': cinema.cityId,
    };
    
    final res = await _dio.put('${ApiEndpoints.cinemas}/${cinema.id}', data: payload);
    return Cinema.fromJson(res.data);
  }

  Future<void> deleteCinema(String cinemaId) async {
    await _dio.delete('${ApiEndpoints.cinemas}/$cinemaId');
  }

  // Hall management methods
  Future<Hall> createHall(String cinemaId, Hall hall) async {
    final payload = {
      'name': hall.name,
      'rowsCount': hall.rowsCount,
      'seatsPerRow': hall.seatsPerRow,
      'capacity': hall.capacity, // Add calculated capacity
      'hallType': hall.hallType,
      'screenSize': hall.screenSize,
      'isDolbyAtmos': hall.isDolbyAtmos,
      'cinemaId': cinemaId, // Add cinemaId as required by API
      'cinemaName': hall.cinemaName, // Add cinemaName as required by API
    };
    
    final res = await _dio.post(ApiEndpoints.halls, data: payload);
    return Hall.fromJson(res.data);
  }

  Future<Hall> updateHall(String cinemaId, Hall hall) async {
    final payload = {
      'name': hall.name,
      'rowsCount': hall.rowsCount,
      'seatsPerRow': hall.seatsPerRow,
      'capacity': hall.capacity, // Add calculated capacity
      'hallType': hall.hallType,
      'screenSize': hall.screenSize,
      'isDolbyAtmos': hall.isDolbyAtmos,
      'cinemaId': cinemaId, // Add cinemaId as required by API
      'cinemaName': hall.cinemaName, // Add cinemaName as required by API
    };
    
    final res = await _dio.put('${ApiEndpoints.halls}/${hall.id}', data: payload);
    return Hall.fromJson(res.data);
  }

  Future<void> deleteHall(String cinemaId, String hallId) async {
    await _dio.delete('${ApiEndpoints.halls}/$hallId');
  }
}
