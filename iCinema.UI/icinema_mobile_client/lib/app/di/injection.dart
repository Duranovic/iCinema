import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../../features/home/data/repositories/home_repository.dart';
import '../../features/home/data/datasources/projections_api_service.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_data_usecase.dart';
import '../../features/home/presentation/bloc/home_cubit.dart';
import '../../features/movies/data/datasources/movies_api_service.dart';
import '../../features/movies/data/datasources/search_api_service.dart';
import '../../features/movies/data/datasources/recommendations_api_service.dart';
import '../../features/movies/data/repositories/movies_repository_impl.dart';
import '../../features/movies/data/repositories/search_repository_impl.dart';
import '../../features/movies/data/repositories/recommendations_repository_impl.dart';
import '../../features/movies/domain/repositories/movies_repository.dart';
import '../../features/movies/domain/usecases/get_movie_by_id_usecase.dart';
import '../../features/movies/domain/usecases/load_repertoire_usecase.dart';
import '../../features/movies/domain/usecases/search_movies_usecase.dart';
import '../../features/movies/domain/usecases/get_similar_movies_usecase.dart';
import '../../features/movies/domain/usecases/get_movie_details_usecase.dart';
import '../../features/movies/domain/usecases/get_my_rating_usecase.dart';
import '../../features/movies/presentation/bloc/movie_details_cubit.dart';
import '../../features/movies/presentation/bloc/similar_movies_cubit.dart';
import '../../features/movies/presentation/bloc/search_cubit.dart';
import '../../features/movies/presentation/bloc/movies_cubit.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/get_me_usecase.dart';
import '../../features/auth/domain/usecases/get_my_reservations_usecase.dart';
import '../../features/auth/domain/usecases/update_profile_usecase.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/reservations_cubit.dart';
import '../../features/reservations/data/datasources/reservation_api_service.dart';
import '../../features/reservations/data/repositories/reservations_repository_impl.dart';
import '../../features/reservations/domain/repositories/reservations_repository.dart';
import '../../features/reservations/domain/usecases/get_seat_map_usecase.dart';
import '../../features/reservations/domain/usecases/get_ticket_qr_usecase.dart';
import '../../features/reservations/presentation/bloc/seat_map_cubit.dart';
import '../../features/reservations/presentation/details/reservation_details_cubit.dart';
import '../../features/reservations/presentation/details/reservation_details_state.dart';
import '../../features/reservations/data/seat_map_refresh_bus.dart';
import '../../features/auth/data/reservations_refresh_bus.dart';
import '../../features/notifications/data/datasources/notifications_api_service.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/presentation/bloc/notifications_cubit.dart';
import '../../features/validation/data/datasources/validation_api_service.dart';
import '../../features/validation/data/repositories/validation_repository_impl.dart';
import '../../features/validation/domain/repositories/validation_repository.dart';
import '../../features/validation/domain/usecases/validate_ticket_usecase.dart';
import '../../features/validation/presentation/bloc/validation_cubit.dart';
import '../services/signalr_service.dart';

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
  
  // SignalR Service for real-time notifications
  getIt.registerLazySingleton<SignalRService>(
    () => SignalRService(getIt<AuthService>(), AppConfig.apiBaseUrl),
  );
  
  // Auth Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<Dio>()),
  );
  
  // Auth Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );
  
  // Auth Use Cases
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<GetMeUseCase>(
    () => GetMeUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<GetMyReservationsPagedUseCase>(
    () => GetMyReservationsPagedUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(getIt<AuthRepository>()),
  );
  
  // API Services/Datasources
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
  // Reservations API/Datasources
  getIt.registerLazySingleton<ReservationApiService>(
    () => ReservationApiService(getIt<Dio>()),
  );
  // Seat map refresh bus
  getIt.registerLazySingleton<SeatMapRefreshBus>(() => SeatMapRefreshBus());
  // Reservations refresh bus (profile lists)
  getIt.registerLazySingleton<ReservationsRefreshBus>(() => ReservationsRefreshBus());
  // Notifications API/Datasources
  getIt.registerLazySingleton<NotificationsApiService>(
    () => NotificationsApiService(getIt<Dio>()),
  );
  // Validation API/Datasources
  getIt.registerLazySingleton<ValidationApiService>(
    () => ValidationApiService(getIt<Dio>()),
  );

  // Home Repositories (register domain interface, implement with data layer)
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      getIt<ProjectionsApiService>(),
      getIt<RecommendationsApiService>(),
    ),
  );

  // Home Use Cases
  getIt.registerLazySingleton<GetHomeDataUseCase>(
    () => GetHomeDataUseCase(getIt<HomeRepository>()),
  );

  // Movies Repositories
  getIt.registerLazySingleton<MoviesRepository>(
    () => MoviesRepositoryImpl(getIt<MoviesApiService>()),
  );
  getIt.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(getIt<SearchApiService>()),
  );
  getIt.registerLazySingleton<RecommendationsRepository>(
    () => RecommendationsRepositoryImpl(getIt<RecommendationsApiService>()),
  );

  // Movies Use Cases
  getIt.registerLazySingleton<GetMovieByIdUseCase>(
    () => GetMovieByIdUseCase(getIt<MoviesRepository>()),
  );
  getIt.registerLazySingleton<GetMoviesByIdsUseCase>(
    () => GetMoviesByIdsUseCase(getIt<MoviesRepository>()),
  );
  getIt.registerLazySingleton<LoadRepertoireUseCase>(
    () => LoadRepertoireUseCase(
      getIt<ProjectionsApiService>(),
      getIt<MoviesRepository>(),
    ),
  );
  getIt.registerLazySingleton<SearchMoviesUseCase>(
    () => SearchMoviesUseCase(getIt<SearchRepository>()),
  );
  getIt.registerLazySingleton<GetSimilarMoviesUseCase>(
    () => GetSimilarMoviesUseCase(getIt<RecommendationsRepository>()),
  );
  getIt.registerLazySingleton<GetMovieDetailsUseCase>(
    () => GetMovieDetailsUseCase(
      getIt<MoviesRepository>(),
      getIt<ProjectionsApiService>(),
    ),
  );
  getIt.registerLazySingleton<GetMyRatingUseCase>(
    () => GetMyRatingUseCase(getIt<MoviesRepository>()),
  );
  getIt.registerLazySingleton<CanRateUseCase>(
    () => CanRateUseCase(getIt<MoviesRepository>()),
  );
  getIt.registerLazySingleton<SaveRatingUseCase>(
    () => SaveRatingUseCase(getIt<MoviesRepository>()),
  );

  // Blocs/Cubits
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(getIt<GetHomeDataUseCase>()),
  );
  getIt.registerFactory<MovieDetailsCubit>(
    () => MovieDetailsCubit(
      getIt<GetMovieDetailsUseCase>(),
      getIt<GetMyRatingUseCase>(),
      getIt<SaveRatingUseCase>(),
      getIt<CanRateUseCase>(),
    ),
  );
  getIt.registerFactory<SimilarMoviesCubit>(
    () => SimilarMoviesCubit(getIt<GetSimilarMoviesUseCase>()),
  );
  getIt.registerFactory<SearchCubit>(
    () => SearchCubit(getIt<SearchMoviesUseCase>()),
  );
  getIt.registerFactory<MoviesCubit>(
    () => MoviesCubit(getIt<LoadRepertoireUseCase>()),
  );

  // Auth Cubit (singleton)
  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      getIt<LoginUseCase>(),
      getIt<RegisterUseCase>(),
      getIt<GetMeUseCase>(),
      getIt<AuthService>(),
      getIt<SignalRService>(),
    ),
  );

  // Reservations cubit (factory with param: status 'Active' | 'Past')
  getIt.registerFactoryParam<ReservationsCubit, String, void>(
    (status, _) => ReservationsCubit(getIt<GetMyReservationsPagedUseCase>(), status: status),
  );

  // Reservations Repositories
  getIt.registerLazySingleton<ReservationsRepository>(
    () => ReservationsRepositoryImpl(getIt<ReservationApiService>()),
  );

  // Reservations Use Cases
  getIt.registerLazySingleton<GetSeatMapUseCase>(
    () => GetSeatMapUseCase(getIt<ReservationsRepository>()),
  );
  getIt.registerLazySingleton<CreateReservationUseCase>(
    () => CreateReservationUseCase(getIt<ReservationsRepository>()),
  );
  getIt.registerLazySingleton<CancelReservationUseCase>(
    () => CancelReservationUseCase(getIt<ReservationsRepository>()),
  );
  getIt.registerLazySingleton<GetTicketsUseCase>(
    () => GetTicketsUseCase(getIt<ReservationsRepository>()),
  );
  getIt.registerLazySingleton<GetTicketQrUseCase>(
    () => GetTicketQrUseCase(getIt<ReservationsRepository>()),
  );

  // Notifications Repositories
  getIt.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(getIt<NotificationsApiService>()),
  );

  // Notifications Use Cases
  getIt.registerLazySingleton<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(getIt<NotificationsRepository>()),
  );
  getIt.registerLazySingleton<MarkNotificationReadUseCase>(
    () => MarkNotificationReadUseCase(getIt<NotificationsRepository>()),
  );
  getIt.registerLazySingleton<DeleteNotificationUseCase>(
    () => DeleteNotificationUseCase(getIt<NotificationsRepository>()),
  );
  getIt.registerLazySingleton<DeleteAllNotificationsUseCase>(
    () => DeleteAllNotificationsUseCase(getIt<NotificationsRepository>()),
  );

  // Validation Repositories
  getIt.registerLazySingleton<ValidationRepository>(
    () => ValidationRepositoryImpl(getIt<ValidationApiService>()),
  );

  // Validation Use Cases
  getIt.registerLazySingleton<ValidateTicketUseCase>(
    () => ValidateTicketUseCase(getIt<ValidationRepository>()),
  );

  // Seat map cubit (factory with param: projectionId)
  getIt.registerFactoryParam<SeatMapCubit, String, void>(
    (projectionId, _) => SeatMapCubit(
      getIt<GetSeatMapUseCase>(),
      getIt<CreateReservationUseCase>(),
      projectionId: projectionId,
    ),
  );

  // Reservation details cubit (factory with params: reservationId, initialHeader)
  getIt.registerFactoryParam<ReservationDetailsCubit, String, ReservationHeader?>(
    (reservationId, initialHeader) => ReservationDetailsCubit(
      getIt<GetTicketsUseCase>(),
      getIt<CancelReservationUseCase>(),
      reservationId: reservationId,
      initialHeader: initialHeader,
    ),
  );

  // Notifications Cubit as singleton so badge and page share the same state
  getIt.registerLazySingleton<NotificationsCubit>(
    () => NotificationsCubit(
      getIt<GetNotificationsUseCase>(),
      getIt<MarkNotificationReadUseCase>(),
      getIt<DeleteNotificationUseCase>(),
      getIt<DeleteAllNotificationsUseCase>(),
      getIt<SignalRService>(),
    ),
  );

  // Validation Cubit
  getIt.registerFactory<ValidationCubit>(
    () => ValidationCubit(getIt<ValidateTicketUseCase>()),
  );
}
