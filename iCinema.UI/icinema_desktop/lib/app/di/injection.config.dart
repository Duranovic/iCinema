// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/datasources/auth_remote_datasource.dart'
    as _i161;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/presentation/blocs/login/login_bloc.dart' as _i1018;
import '../../features/cinemas/data/city_service.dart' as _i1012;
import '../../features/cinemas/presentation/bloc/cinemas_bloc.dart' as _i415;
import '../../features/movies/data/movie_service.dart' as _i1055;
import '../../features/movies/presentation/bloc/movies_bloc.dart' as _i169;
import '../../features/projections/data/cinema_service.dart' as _i468;
import '../../features/projections/data/projection_service.dart' as _i963;
import '../../features/projections/presentation/bloc/projections_bloc.dart'
    as _i850;
import '../../features/reports/data/reports_service.dart' as _i653;
import 'network_module.dart' as _i567;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i161.AuthRemoteDataSource>(
        () => _i161.AuthRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i468.CinemaService>(
        () => _i468.CinemaService(gh<_i361.Dio>()));
    gh.lazySingleton<_i963.ProjectionService>(
        () => _i963.ProjectionService(gh<_i361.Dio>()));
    gh.lazySingleton<_i1012.CityService>(
        () => _i1012.CityService(gh<_i361.Dio>()));
    gh.lazySingleton<_i1055.MovieService>(
        () => _i1055.MovieService(gh<_i361.Dio>()));
    gh.lazySingleton<_i653.ReportsService>(
        () => _i653.ReportsService(gh<_i361.Dio>()));
    gh.lazySingleton<_i787.AuthRepository>(
        () => _i153.AuthRepositoryImpl(gh<_i161.AuthRemoteDataSource>()));
    gh.factory<_i415.CinemasBloc>(() => _i415.CinemasBloc(
          gh<_i468.CinemaService>(),
          gh<_i1012.CityService>(),
        ));
    gh.factory<_i188.LoginUseCase>(
        () => _i188.LoginUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i169.MoviesBloc>(
        () => _i169.MoviesBloc(gh<_i1055.MovieService>()));
    gh.factory<_i850.ProjectionsBloc>(() => _i850.ProjectionsBloc(
          gh<_i963.ProjectionService>(),
          gh<_i468.CinemaService>(),
        ));
    gh.factory<_i1018.LoginBloc>(
        () => _i1018.LoginBloc(gh<_i188.LoginUseCase>()));
    return this;
  }
}

class _$NetworkModule extends _i567.NetworkModule {}
