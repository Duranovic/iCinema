import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/data/models/projection_model.dart';
import '../../../home/data/datasources/projections_api_service.dart';
import '../../data/models/movie_model.dart';
import '../../domain/usecases/load_repertoire_usecase.dart';

// States
abstract class MoviesState {
  const MoviesState();
}

class MoviesInitial extends MoviesState {
  const MoviesInitial();
}

class MoviesLoading extends MoviesState {
  const MoviesLoading();
}

class MoviesError extends MoviesState {
  final String message;
  final String? errorType;
  const MoviesError({required this.message, this.errorType});
}

class MoviesLoaded extends MoviesState {
  final List<ProjectionModel> projections;
  final DateTime from;
  final DateTime to;
  final Map<String, MovieModel> moviesById;

  const MoviesLoaded({
    required this.projections,
    required this.from,
    required this.to,
    required this.moviesById,
  });

  Map<DateTime, List<ProjectionModel>> groupByDate() {
    final Map<DateTime, List<ProjectionModel>> groups = {};
    for (final p in projections) {
      final d = DateTime(p.startTime.year, p.startTime.month, p.startTime.day);
      (groups[d] ??= []).add(p);
    }
    for (final list in groups.values) {
      list.sort((a, b) => a.startTime.compareTo(b.startTime));
    }
    return Map.fromEntries(groups.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key)));
  }
}

// Cubit
class MoviesCubit extends Cubit<MoviesState> {
  final LoadRepertoireUseCase _loadRepertoireUseCase;
  
  MoviesCubit(this._loadRepertoireUseCase) : super(const MoviesInitial());

  Future<void> loadRepertoire({int daysAhead = 14}) async {
    emit(const MoviesLoading());
    try {
      final now = DateTime.now();
      final from = DateTime(now.year, now.month, now.day);
      final toBase = now.add(Duration(days: daysAhead));
      final to = DateTime(toBase.year, toBase.month, toBase.day, 23, 59, 59);

      final (projections, moviesById) = await _loadRepertoireUseCase(from: from, to: to);
      
      emit(MoviesLoaded(
        projections: projections,
        from: from,
        to: to,
        moviesById: moviesById,
      ));
    } on ProjectionsNotFoundException {
      emit(const MoviesError(
        message: 'Nema dostupnih projekcija u odabranom periodu.',
        errorType: 'not_found',
      ));
    } on ProjectionsNetworkException {
      emit(const MoviesError(
        message: 'Greška u mrežnoj konekciji. Molimo pokušajte ponovo.',
        errorType: 'network',
      ));
    } on ProjectionsServerException {
      emit(const MoviesError(
        message: 'Greška na serveru. Molimo pokušajte kasnije.',
        errorType: 'server',
      ));
    } catch (e) {
      emit(MoviesError(
        message: 'Dogodila se neočekivana greška: ${e.toString()}',
        errorType: 'unknown',
      ));
    }
  }
}
