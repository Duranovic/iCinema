import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/reference_service.dart';
import '../../domain/city.dart';
import 'package:icinema_shared/icinema_shared.dart';

class CitiesState {
  final bool loading;
  final List<City> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final String? error;
  final String search;
  final String countryId;

  CitiesState({
    required this.loading,
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.search,
    required this.countryId,
    this.error,
  });

  factory CitiesState.initial() => CitiesState(
        loading: false,
        items: const [],
        page: 1,
        pageSize: 20,
        totalCount: 0,
        search: '',
        countryId: '',
      );

  CitiesState copyWith({
    bool? loading,
    List<City>? items,
    int? page,
    int? pageSize,
    int? totalCount,
    String? error,
    String? search,
    String? countryId,
  }) => CitiesState(
        loading: loading ?? this.loading,
        items: items ?? this.items,
        page: page ?? this.page,
        pageSize: pageSize ?? this.pageSize,
        totalCount: totalCount ?? this.totalCount,
        error: error,
        search: search ?? this.search,
        countryId: countryId ?? this.countryId,
      );
}

class CitiesCubit extends Cubit<CitiesState> {
  final ReferenceService _service;
  CitiesCubit(this._service) : super(CitiesState.initial());

  Future<void> load({int? page, String? search, String? countryId}) async {
    emit(state.copyWith(
      loading: true,
      error: null,
      page: page ?? state.page,
      search: search ?? state.search,
      countryId: countryId ?? state.countryId,
    ));
    try {
      final PagedResult<City> res = await _service.getCities(
        page: state.page,
        pageSize: state.pageSize,
        search: state.search.isEmpty ? null : state.search,
        countryId: state.countryId.isEmpty ? null : state.countryId,
      );
      emit(state.copyWith(
        loading: false,
        items: res.items,
        totalCount: res.totalCount,
        page: res.page,
        pageSize: res.pageSize,
      ));
    } catch (e) {
      final msg = e is DioException ? (e.message ?? 'Došlo je do greške.') : e.toString();
      emit(state.copyWith(loading: false, error: msg));
    }
  }

  Future<void> create({required String name, required String countryId}) async {
    try {
      emit(state.copyWith(loading: true));
      await _service.createCity(name: name, countryId: countryId);
      await load(page: 1);
    } catch (e) {
      final msg = e is DioException ? (e.message ?? 'Došlo je do greške.') : e.toString();
      emit(state.copyWith(loading: false, error: msg));
    }
  }

  Future<void> update({required String id, required String name, required String countryId}) async {
    try {
      emit(state.copyWith(loading: true));
      await _service.updateCity(id: id, name: name, countryId: countryId);
      await load(page: state.page);
    } catch (e) {
      final msg = e is DioException ? (e.message ?? 'Došlo je do greške.') : e.toString();
      emit(state.copyWith(loading: false, error: msg));
    }
  }

  Future<void> delete(String id) async {
    try {
      emit(state.copyWith(loading: true));
      await _service.deleteCity(id);
      final newPage = state.items.length == 1 && state.page > 1 ? state.page - 1 : state.page;
      await load(page: newPage);
    } catch (e) {
      final msg = e is DioException ? (e.message ?? 'Došlo je do greške.') : e.toString();
      emit(state.copyWith(loading: false, error: msg));
    }
  }

  void clearError() {
    if (state.error != null) {
      emit(state.copyWith(error: null));
    }
  }
}
