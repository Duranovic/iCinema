import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../../features/home/data/repositories/home_repository.dart';
import '../../features/home/data/services/projections_api_service.dart';
import '../../features/home/presentation/bloc/home_cubit.dart';
import '../../features/movies/data/services/movies_api_service.dart';
import '../../features/movies/presentation/bloc/movie_details_cubit.dart';
import '../../features/movies/data/services/search_api_service.dart';
import '../../features/movies/presentation/bloc/search_cubit.dart';

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
  // API Services
  getIt.registerLazySingleton<ProjectionsApiService>(
    () => ProjectionsApiService(getIt()),
  );
  getIt.registerLazySingleton<MoviesApiService>(
    () => MoviesApiService(getIt()),
  );
  getIt.registerLazySingleton<SearchApiService>(
    () => SearchApiService(getIt()),
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
  getIt.registerFactory<SearchCubit>(
    () => SearchCubit(getIt<SearchApiService>()),
  );
}
