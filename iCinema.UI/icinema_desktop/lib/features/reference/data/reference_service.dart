import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:icinema_shared/icinema_shared.dart';
import '../domain/country.dart';
import '../domain/city.dart';
import '../domain/genre.dart';
import '../domain/director.dart';
import '../domain/actor.dart';

class ReferenceService {
  final Dio _dio = GetIt.I<Dio>();

  Future<PagedResult<Country>> getCountries({int page = 1, int pageSize = 20, String? search}) async {
    final res = await _dio.get(
      ApiEndpoints.countries,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final data = res.data as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>).map((e) => Country.fromJson(e as Map<String, dynamic>)).toList();
    return PagedResult<Country>(
      items: items,
      totalCount: (data['totalCount'] as num?)?.toInt() ?? items.length,
      page: (data['page'] as num?)?.toInt() ?? page,
      pageSize: (data['pageSize'] as num?)?.toInt() ?? pageSize,
    );
  }

  Future<PagedResult<City>> getCities({int page = 1, int pageSize = 20, String? search, String? countryId}) async {
    final res = await _dio.get(
      ApiEndpoints.cities,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
        if (countryId != null && countryId.isNotEmpty) 'countryId': countryId,
      },
    );
    final data = res.data as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>).map((e) => City.fromJson(e as Map<String, dynamic>)).toList();
    return PagedResult<City>(
      items: items,
      totalCount: (data['totalCount'] as num?)?.toInt() ?? items.length,
      page: (data['page'] as num?)?.toInt() ?? page,
      pageSize: (data['pageSize'] as num?)?.toInt() ?? pageSize,
    );
  }

  Future<PagedResult<Genre>> getGenres({int page = 1, int pageSize = 20, String? search}) async {
    final res = await _dio.get(
      ApiEndpoints.genres,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final data = res.data as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>).map((e) => Genre.fromJson(e as Map<String, dynamic>)).toList();
    return PagedResult<Genre>(
      items: items,
      totalCount: (data['totalCount'] as num?)?.toInt() ?? items.length,
      page: (data['page'] as num?)?.toInt() ?? page,
      pageSize: (data['pageSize'] as num?)?.toInt() ?? pageSize,
    );
  }

  Future<PagedResult<Director>> getDirectors({int page = 1, int pageSize = 20, String? search}) async {
    final res = await _dio.get(
      ApiEndpoints.directors,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final data = res.data as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>).map((e) => Director.fromJson(e as Map<String, dynamic>)).toList();
    return PagedResult<Director>(
      items: items,
      totalCount: (data['totalCount'] as num?)?.toInt() ?? items.length,
      page: (data['page'] as num?)?.toInt() ?? page,
      pageSize: (data['pageSize'] as num?)?.toInt() ?? pageSize,
    );
  }

  // Countries CRUD
  Future<Country> createCountry({required String name}) async {
    final res = await _dio.post(ApiEndpoints.countries, data: {'name': name});
    return Country.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Country> updateCountry({required String id, required String name}) async {
    final res = await _dio.put('${ApiEndpoints.countries}/$id', data: {'name': name});
    return Country.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteCountry(String id) async {
    await _dio.delete('${ApiEndpoints.countries}/$id');
  }

  // Cities CRUD
  Future<City> createCity({required String name, required String countryId}) async {
    final res = await _dio.post(ApiEndpoints.cities, data: {'name': name, 'countryId': countryId});
    return City.fromJson(res.data as Map<String, dynamic>);
  }

  Future<City> updateCity({required String id, required String name, required String countryId}) async {
    final res = await _dio.put('${ApiEndpoints.cities}/$id', data: {'name': name, 'countryId': countryId});
    return City.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteCity(String id) async {
    await _dio.delete('${ApiEndpoints.cities}/$id');
  }

  // Genres CRUD
  Future<Genre> createGenre({required String name}) async {
    final res = await _dio.post(ApiEndpoints.genres, data: {'name': name});
    return Genre.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Genre> updateGenre({required String id, required String name}) async {
    final res = await _dio.put('${ApiEndpoints.genres}/$id', data: {'name': name});
    return Genre.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteGenre(String id) async {
    await _dio.delete('${ApiEndpoints.genres}/$id');
  }

  // Directors CRUD
  Future<Director> createDirector({required String fullName}) async {
    final res = await _dio.post(ApiEndpoints.directors, data: {'fullName': fullName});
    return Director.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Director> updateDirector({required String id, required String fullName}) async {
    final res = await _dio.put('${ApiEndpoints.directors}/$id', data: {'fullName': fullName});
    return Director.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteDirector(String id) async {
    await _dio.delete('${ApiEndpoints.directors}/$id');
  }

  // Actors CRUD
  Future<PagedResult<Actor>> getActors({int page = 1, int pageSize = 20, String? search}) async {
    final res = await _dio.get(
      ApiEndpoints.actors,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final data = res.data as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>)
        .map((e) => Actor.fromJson(e as Map<String, dynamic>))
        .toList();
    return PagedResult<Actor>(
      items: items,
      totalCount: (data['totalCount'] as num?)?.toInt() ?? items.length,
      page: (data['page'] as num?)?.toInt() ?? page,
      pageSize: (data['pageSize'] as num?)?.toInt() ?? pageSize,
    );
  }

  Future<Actor> createActor({required String fullName}) async {
    final res = await _dio.post(ApiEndpoints.actors, data: {'fullName': fullName});
    return Actor.fromJson(res.data as Map<String, dynamic>);
    }

  Future<Actor> updateActor({required String id, required String fullName}) async {
    final res = await _dio.put('${ApiEndpoints.actors}/$id', data: {'fullName': fullName});
    return Actor.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteActor(String id) async {
    await _dio.delete('${ApiEndpoints.actors}/$id');
  }

  Future<List<Map<String, dynamic>>> getActorItems() async {
    final res = await _dio.get(ApiEndpoints.actorsItems);
    final items = (res.data as List<dynamic>).whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    return items;
  }
}
