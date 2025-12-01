import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/reference_service.dart';
import '../../domain/actor.dart';
import 'package:icinema_shared/icinema_shared.dart';

class ActorsState {
  final bool loading;
  final String? error;
  final String? success;
  final List<Actor> items;
  final int page;
  final int pageSize;
  final int totalCount;

  ActorsState({
    required this.loading,
    required this.error,
    this.success,
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  factory ActorsState.initial() => ActorsState(
        loading: false,
        error: null,
        success: null,
        items: const [],
        page: 1,
        pageSize: 20,
        totalCount: 0,
      );

  ActorsState copyWith({
    bool? loading,
    String? error,
    String? success,
    List<Actor>? items,
    int? page,
    int? pageSize,
    int? totalCount,
  }) => ActorsState(
        loading: loading ?? this.loading,
        error: error, // Clears error if not provided (intentional)
        success: success, // Clears success if not provided (intentional)
        items: items ?? this.items,
        page: page ?? this.page,
        pageSize: pageSize ?? this.pageSize,
        totalCount: totalCount ?? this.totalCount,
      );
}

class ActorsCubit extends Cubit<ActorsState> {
  final ReferenceService service;
  ActorsCubit(this.service) : super(ActorsState.initial());

  Future<void> load({int page = 1, String? search, String? successMessage}) async {
    emit(state.copyWith(loading: true, error: null, success: null));
    try {
      final PagedResult<Actor> res = await service.getActors(page: page, pageSize: state.pageSize, search: search);
      emit(ActorsState(
        loading: false,
        error: null,
        success: successMessage,
        items: res.items,
        page: res.page,
        pageSize: res.pageSize,
        totalCount: res.totalCount,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void clearError() => emit(state.copyWith(error: null));
  void clearSuccess() => emit(state.copyWith(success: null));

  Future<void> create(String fullName) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await service.createActor(fullName: fullName);
      await load(page: 1, successMessage: 'Glumac uspješno dodan');
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> update(String id, String fullName) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await service.updateActor(id: id, fullName: fullName);
      await load(page: state.page, successMessage: 'Glumac uspješno ažuriran');
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> delete(String id) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await service.deleteActor(id);
      await load(page: state.page, successMessage: 'Glumac uspješno obrisan');
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
