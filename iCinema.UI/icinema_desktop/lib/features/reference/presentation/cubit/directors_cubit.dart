import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/reference_service.dart';
import '../../domain/director.dart';
import 'package:icinema_shared/icinema_shared.dart';

class DirectorsState {
  final bool loading;
  final List<Director> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final String? error;
  final String? success;
  final String search;

  DirectorsState({
    required this.loading,
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.search,
    this.error,
    this.success,
  });

  factory DirectorsState.initial() => DirectorsState(
        loading: false,
        items: const [],
        page: 1,
        pageSize: 20,
        totalCount: 0,
        search: '',
        error: null,
        success: null,
      );

  DirectorsState copyWith({
    bool? loading,
    List<Director>? items,
    int? page,
    int? pageSize,
    int? totalCount,
    String? error,
    String? success,
    String? search,
  }) => DirectorsState(
        loading: loading ?? this.loading,
        items: items ?? this.items,
        page: page ?? this.page,
        pageSize: pageSize ?? this.pageSize,
        totalCount: totalCount ?? this.totalCount,
        error: error, // Clears if null (default)
        success: success, // Clears if null (default)
        search: search ?? this.search,
      );
}

class DirectorsCubit extends Cubit<DirectorsState> {
  final ReferenceService _service;
  DirectorsCubit(this._service) : super(DirectorsState.initial());

  Future<void> load({int? page, String? search, String? successMessage}) async {
    emit(state.copyWith(
      loading: true, 
      error: null, 
      success: null, 
      page: page ?? state.page, 
      search: search ?? state.search
    ));
    try {
      final PagedResult<Director> res = await _service.getDirectors(
        page: state.page,
        pageSize: state.pageSize,
        search: state.search.isEmpty ? null : state.search,
      );
      emit(DirectorsState(
        loading: false,
        items: res.items,
        totalCount: res.totalCount,
        page: res.page,
        pageSize: res.pageSize,
        search: state.search,
        success: successMessage,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> create(String fullName) async {
    try {
      emit(state.copyWith(loading: true));
      await _service.createDirector(fullName: fullName);
      await load(page: 1, successMessage: 'Režiser uspješno dodan');
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> update(String id, String fullName) async {
    try {
      emit(state.copyWith(loading: true));
      await _service.updateDirector(id: id, fullName: fullName);
      await load(page: state.page, successMessage: 'Režiser uspješno ažuriran');
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> delete(String id) async {
    try {
      emit(state.copyWith(loading: true));
      await _service.deleteDirector(id);
      final newPage = state.items.length == 1 && state.page > 1 ? state.page - 1 : state.page;
      await load(page: newPage, successMessage: 'Režiser uspješno obrisan');
    } catch (e) {
      // Rely on global Dio interceptor for normalized messages (e.message)
      String message = 'Došlo je do greške.';
      if (e is DioException) {
        message = e.message ?? message;
      } else {
        message = e.toString();
      }
      emit(state.copyWith(loading: false, error: message));
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
