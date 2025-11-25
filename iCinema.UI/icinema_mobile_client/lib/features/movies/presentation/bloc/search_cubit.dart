import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/search_movies_usecase.dart';
import '../../data/models/movie_model.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {
  final List<String> recentQueries;
  SearchInitial({this.recentQueries = const []});
}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<MovieModel> items;
  final int total;
  final int page;
  final int pageSize;
  bool get hasMore => items.length < total;
  SearchLoaded({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });
}

class SearchEmpty extends SearchState {
  final String query;
  SearchEmpty(this.query);
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

class SearchCubit extends Cubit<SearchState> {
  final SearchMoviesUseCase _searchMoviesUseCase;
  Timer? _debounce;
  String _currentQuery = '';
  int _page = 1;
  final int _pageSize = 20;
  bool _isLoadingMore = false;
  List<MovieModel> _buffer = [];

  SearchCubit(this._searchMoviesUseCase) : super(SearchInitial());

  void onQueryChanged(String q) {
    _currentQuery = q.trim();

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (_currentQuery.isEmpty) {
        emit(SearchInitial());
        return;
      }
      _page = 1;
      _search(reset: true);
    });
  }

  Future<void> loadMore() async {
    if (_isLoadingMore) return;
    final current = state;
    if (current is SearchLoaded && current.hasMore) {
      _isLoadingMore = true;
      _page += 1;
      try {
        final res = await _searchMoviesUseCase(search: _currentQuery, page: _page, pageSize: _pageSize);
        _buffer.addAll(res.items);
        emit(SearchLoaded(items: List<MovieModel>.from(_buffer), total: res.total, page: res.page, pageSize: res.pageSize));
      } catch (e) {
        // Keep existing items but you could show a toast/snackbar in UI
      } finally {
        _isLoadingMore = false;
      }
    }
  }

  Future<void> retry() async {
    if (_currentQuery.isEmpty) return;
    await _search(reset: true);
  }

  Future<void> _search({bool reset = false}) async {
    try {
      emit(SearchLoading());
      final res = await _searchMoviesUseCase(search: _currentQuery, page: 1, pageSize: _pageSize);
      if (res.items.isEmpty) {
        _buffer = [];
        emit(SearchEmpty(_currentQuery));
        return;
      }
      _page = 1;
      _buffer = List<MovieModel>.from(res.items);
      emit(SearchLoaded(items: _buffer, total: res.total, page: res.page, pageSize: res.pageSize));
    } catch (e) {
      emit(SearchError('Došlo je do greške. Pokušaj ponovo.'));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
