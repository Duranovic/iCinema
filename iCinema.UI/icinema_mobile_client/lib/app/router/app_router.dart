import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../layout/app_shell.dart';
import '../di/injection.dart';
import '../services/auth_service.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/bloc/home_cubit.dart';
import '../../features/movies/presentation/pages/movies_page.dart';
import '../../features/movies/presentation/pages/movie_details_page.dart';
import '../../features/movies/presentation/bloc/movie_details_cubit.dart';
import '../../features/movies/presentation/pages/search_page.dart';
import '../../features/movies/presentation/bloc/search_cubit.dart';
import '../../features/movies/presentation/bloc/movies_cubit.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/login_sheet_launcher_page.dart';
import '../../features/home/data/models/projection_model.dart';
import '../../features/reservations/presentation/pages/reservation_page.dart';
import '../../features/reservations/presentation/bloc/seat_map_cubit.dart';
import '../../features/reservations/presentation/details/reservation_details_cubit.dart';
import '../../features/reservations/presentation/details/reservation_details_page.dart';
import '../../features/reservations/data/services/reservation_api_service.dart';
import '../../features/reservations/presentation/details/reservation_details_state.dart';
import '../../features/notifications/presentation/bloc/notifications_cubit.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';

// Global route observer for RouteAware widgets
final RouteObserver<ModalRoute<dynamic>> routeObserver = RouteObserver<ModalRoute<dynamic>>();

// Helper function for simple fade transition
Page<void> _fadeTransitionPage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, _, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

// Helper function for slide transition (for movie details)
Page<void> _slideTransitionPage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, _, child) {
      return SlideTransition(
        position: animation.drive(
          Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(
            CurveTween(curve: Curves.easeInOut),
          ),
        ),
        child: child,
      );
    },
  );
}

GoRouter buildRouter() {
  // Defensive: ensure AuthService is registered (hot reload/init order safety)
  if (!getIt.isRegistered<AuthService>()) {
    final service = AuthService();
    getIt.registerSingleton<AuthService>(service);
    // fire-and-forget init; when ready it will notify listeners and router will refresh
    service.init();
  }
  final auth = getIt<AuthService>();
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: auth.authState,
    observers: [routeObserver],
    redirect: (context, state) {
      final loggedIn = auth.authState.isAuthenticated;
      final loggingIn = state.matchedLocation == '/login';
      // Do not force redirect to /profile after login; allow flow to return to the origin page
      // If user is already logged in and navigates to /login manually, just stay (or login page can pop itself)
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(currentLocation: state.uri.toString(), child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => _fadeTransitionPage(
              BlocProvider<HomeCubit>(
                create: (_) => getIt<HomeCubit>()..loadHomeData(),
                child: const HomePage(),
              ),
              state,
            ),
          ),
          GoRoute(
            path: '/movies',
            pageBuilder: (context, state) => _fadeTransitionPage(
              BlocProvider<MoviesCubit>(
                create: (_) => getIt<MoviesCubit>()..loadRepertoire(),
                child: const MoviesPage(),
              ),
              state,
            ),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => _fadeTransitionPage(
              BlocProvider<SearchCubit>(
                create: (_) => getIt<SearchCubit>(),
                child: const SearchPage(),
              ),
              state,
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => _fadeTransitionPage(
              const ProfilePage(),
              state,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _fadeTransitionPage(
          const LoginSheetLauncherPage(),
          state,
        ),
      ),
      // Movie details route (outside shell - full screen)
      GoRoute(
        path: '/movie-details/:movieId',
        pageBuilder: (context, state) {
          final movieId = state.pathParameters['movieId'] ?? '';
          // Be defensive: extra may be null or a loosely-typed List after redirects
          final extra = state.extra;
          List<ProjectionModel> projections;
          if (extra is List<ProjectionModel>) {
            projections = extra;
          } else if (extra is List) {
            projections = extra.whereType<ProjectionModel>().toList();
          } else {
            projections = const [];
          }

          return _slideTransitionPage(
            BlocProvider<MovieDetailsCubit>(
              create: (_) => getIt<MovieDetailsCubit>(),
              child: MovieDetailsPage(
                movieId: Uri.decodeComponent(movieId),
                projections: projections,
              ),
            ),
            state,
          );
        },
      ),
      // Reservation route (outside shell - full screen)
      GoRoute(
        path: '/projections/:id/reserve',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _slideTransitionPage(
            BlocProvider<SeatMapCubit>(
              create: (_) => getIt<SeatMapCubit>(param1: id)..loadMap(),
              child: ReservationPage(projectionId: Uri.decodeComponent(id)),
            ),
            state,
          );
        },
      ),
      // Reservation details route
      GoRoute(
        path: '/reservations/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final extra = state.extra;
          final header = extra is ReservationHeader ? extra : null;
          return _slideTransitionPage(
            BlocProvider<ReservationDetailsCubit>(
              create: (_) => ReservationDetailsCubit(
                getIt<ReservationApiService>(),
                reservationId: id,
                initialHeader: header,
              )..load(),
              child: ReservationDetailsPage(reservationId: Uri.decodeComponent(id)),
            ),
            state,
          );
        },
      ),
      // Notifications route
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => _fadeTransitionPage(
          BlocProvider<NotificationsCubit>(
            create: (_) => getIt<NotificationsCubit>()..load(),
            child: const NotificationsPage(),
          ),
          state,
        ),
      ),
    ],
  );
}
