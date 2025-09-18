import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../services/auth_service.dart';
import '../../features/home/data/repositories/home_repository.dart';
import '../../features/home/data/services/projections_api_service.dart';
import '../../features/home/presentation/bloc/home_cubit.dart';
import '../../features/movies/data/services/movies_api_service.dart';
import '../../features/movies/presentation/bloc/movie_details_cubit.dart';
import '../../features/movies/presentation/bloc/similar_movies_cubit.dart';
import '../../features/movies/data/services/search_api_service.dart';
import '../../features/movies/data/services/recommendations_api_service.dart';
import '../../features/movies/presentation/bloc/search_cubit.dart';
import '../../features/movies/presentation/bloc/movies_cubit.dart';
import '../../features/auth/data/services/auth_api_service.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  // Initialize injectable dependencies (this registers Dio from NetworkModule)
  getIt.init();
  
  // Register additional dependencies that are not auto-generated
  // Auth
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  await getIt<AuthService>().init();
  // API Services
  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<ProjectionsApiService>(
    () => ProjectionsApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<MoviesApiService>(
    () => MoviesApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<SearchApiService>(
    () => SearchApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<RecommendationsApiService>(
    () => RecommendationsApiService(getIt<Dio>()),
  );

  // Repositories
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(getIt<ProjectionsApiService>()),
  );

  // Blocs/Cubits
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(getIt<HomeRepository>()),
  );
  getIt.registerFactory<MovieDetailsCubit>(
    () => MovieDetailsCubit(
      getIt<MoviesApiService>(),
      getIt<ProjectionsApiService>(),
    ),
  );
  getIt.registerFactory<SimilarMoviesCubit>(
    () => SimilarMoviesCubit(getIt<RecommendationsApiService>()),
  );
  getIt.registerFactory<SearchCubit>(
    () => SearchCubit(getIt<SearchApiService>()),
  );
  getIt.registerFactory<MoviesCubit>(
    () => MoviesCubit(
      getIt<ProjectionsApiService>(),
      getIt<MoviesApiService>(),
    ),
  );

  // Auth Cubit (singleton)
  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(getIt<AuthApiService>(), getIt<AuthService>()),
  );
}
