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
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/login_sheet_launcher_page.dart';
import '../../features/home/data/models/projection_model.dart';
import '../../features/movies/presentation/bloc/movies_cubit.dart';

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
    redirect: (context, state) {
      final loggedIn = auth.authState.isAuthenticated;
      final loggingIn = state.matchedLocation == '/login';
      if (loggedIn && loggingIn) {
        return '/profile';
      }
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
          final projections = state.extra as List<ProjectionModel>? ?? [];
          
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
    ],
  );
}
