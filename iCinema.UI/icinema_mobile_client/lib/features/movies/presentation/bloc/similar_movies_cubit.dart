import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/movie_score_dto.dart';
import '../../domain/usecases/get_similar_movies_usecase.dart';

// States
abstract class SimilarMoviesState {}

class SimilarMoviesInitial extends SimilarMoviesState {}

class SimilarMoviesLoading extends SimilarMoviesState {}

class SimilarMoviesLoaded extends SimilarMoviesState {
  final List<MovieScoreDto> items;
  SimilarMoviesLoaded(this.items);
}

class SimilarMoviesError extends SimilarMoviesState {
  final String message;
  SimilarMoviesError(this.message);
}

@injectable
class SimilarMoviesCubit extends Cubit<SimilarMoviesState> {
  final GetSimilarMoviesUseCase _getSimilarMoviesUseCase;
  SimilarMoviesCubit(this._getSimilarMoviesUseCase) : super(SimilarMoviesInitial());

  Future<void> loadSimilar(String movieId, {int top = 10}) async {
    emit(SimilarMoviesLoading());
    try {
      final result = await _getSimilarMoviesUseCase(movieId: movieId, top: top);
      emit(SimilarMoviesLoaded(result));
    } catch (e) {
      emit(SimilarMoviesError('Greška pri dohvaćanju sličnih filmova. Pokušajte ponovo.'));
    }
  }
}
