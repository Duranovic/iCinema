import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/reference_service.dart';
import '../../domain/genre.dart';
import 'package:icinema_shared/icinema_shared.dart';

class GenresState {
  final bool loading;
  final List<Genre> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final String? error;
  final String? success;
  final String search;

  GenresState({
    required this.loading,
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.search,
    this.error,
    this.success,
  });

  factory GenresState.initial() => GenresState(
        loading: false,
        items: const [],
        page: 1,
        pageSize: 20,
        totalCount: 0,
        search: '',
        error: null,
        success: null,
      );

  GenresState copyWith({
    bool? loading,
    List<Genre>? items,
    int? page,
    int? pageSize,
    int? totalCount,
    String? error,
    String? success,
    String? search,
  }) => GenresState(
        loading: loading ?? this.loading,
        items: items ?? this.items,
        page: page ?? this.page,
        pageSize: pageSize ?? this.pageSize,
        totalCount: totalCount ?? this.totalCount,
        error: error, // Clears if not provided
        success: success, // Clears if not provided
        search: search ?? this.search,
      );
}

class GenresCubit extends Cubit<GenresState> {
  final ReferenceService _service;
  GenresCubit(this._service) : super(GenresState.initial());

  Future<void> load({int? page, String? search, String? successMessage}) async {
    emit(state.copyWith(
      loading: true, 
      error: null, 
      success: null, 
      page: page ?? state.page, 
      search: search ?? state.search
    ));
    try {
      final PagedResult<Genre> res = await _service.getGenres(
        page: state.page,
        pageSize: state.pageSize,
        search: state.search.isEmpty ? null : state.search,
      );
      emit(GenresState(
        loading: false,
        items: res.items,
        totalCount: res.totalCount,
        page: res.page,
        pageSize: res.pageSize,
        search: state.search,
        success: successMessage,
      ));
    } catch (e) {
      final msg = e is DioException ? (e.message ?? 'Došlo je do greške.') : e.toString();
      emit(state.copyWith(loading: false, error: msg));
    }
  }

  Future<void> create(String name) async {
    try {
      emit(state.copyWith(loading: true));
      await _service.createGenre(name: name);
      await load(page: 1, successMessage: 'Žanr uspješno dodan');
    } catch (e) {
      final msg = e is DioException ? (e.message ?? 'Došlo je do greške.') : e.toString();
      emit(state.copyWith(loading: false, error: msg));
    }
  }

  Future<void> update(String id, String name) async {
    try {
      emit(state.copyWith(loading: true));
      await _service.updateGenre(id: id, name: name);
      await load(page: state.page, successMessage: 'Žanr uspješno ažuriran');
    } catch (e) {
      final msg = e is DioException ? (e.message ?? 'Došlo je do greške.') : e.toString();
      emit(state.copyWith(loading: false, error: msg));
    }
  }

  Future<void> delete(String id) async {
    try {
      emit(state.copyWith(loading: true));
      await _service.deleteGenre(id);
      final newPage = state.items.length == 1 && state.page > 1 ? state.page - 1 : state.page;
      await load(page: newPage, successMessage: 'Žanr uspješno obrisan');
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

  void clearSuccess() {
    if (state.success != null) {
      emit(state.copyWith(success: null));
    }
  }
}
