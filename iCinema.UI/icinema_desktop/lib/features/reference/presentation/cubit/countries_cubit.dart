import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/reference_service.dart';
import '../../domain/country.dart';
import '../../domain/paged_result.dart';

class CountriesState {
  final bool loading;
  final List<Country> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final String? error;
  final String search;

  CountriesState({
    required this.loading,
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.search,
    this.error,
  });

  factory CountriesState.initial() => CountriesState(
        loading: false,
        items: const [],
        page: 1,
        pageSize: 20,
        totalCount: 0,
        search: '',
      );

  CountriesState copyWith({
    bool? loading,
    List<Country>? items,
    int? page,
    int? pageSize,
    int? totalCount,
    String? error,
    String? search,
  }) => CountriesState(
        loading: loading ?? this.loading,
        items: items ?? this.items,
        page: page ?? this.page,
        pageSize: pageSize ?? this.pageSize,
        totalCount: totalCount ?? this.totalCount,
        error: error,
        search: search ?? this.search,
      );
}

class CountriesCubit extends Cubit<CountriesState> {
  final ReferenceService _service;
  CountriesCubit(this._service) : super(CountriesState.initial());

  Future<void> load({int? page, String? search}) async {
    emit(state.copyWith(loading: true, error: null, page: page ?? state.page, search: search ?? state.search));
    try {
      final PagedResult<Country> res = await _service.getCountries(
        page: state.page,
        pageSize: state.pageSize,
        search: state.search.isEmpty ? null : state.search,
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

  Future<void> create(String name) async {
    try {
      emit(state.copyWith(loading: true));
      await _service.createCountry(name: name);
      await load(page: 1);
    } catch (e) {
      final msg = e is DioException ? (e.message ?? 'Došlo je do greške.') : e.toString();
      emit(state.copyWith(loading: false, error: msg));
    }
  }

  Future<void> update(String id, String name) async {
    try {
      emit(state.copyWith(loading: true));
      await _service.updateCountry(id: id, name: name);
      await load(page: state.page);
    } catch (e) {
      final msg = e is DioException ? (e.message ?? 'Došlo je do greške.') : e.toString();
      emit(state.copyWith(loading: false, error: msg));
    }
  }

  Future<void> delete(String id) async {
    try {
      emit(state.copyWith(loading: true));
      await _service.deleteCountry(id);
      // If last item on page removed, move one page back when possible
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
