import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icinema_desktop/app/di/injection.dart';
import 'package:icinema_desktop/app/services/auth_service.dart';
import 'package:icinema_desktop/app/layout/app_shell.dart';
import 'package:icinema_desktop/features/auth/presentation/blocs/login/login_bloc.dart';
import 'package:icinema_desktop/features/auth/presentation/pages/login_page.dart';
import 'package:icinema_desktop/features/movies/presentation/bloc/movies_bloc.dart';
import 'package:icinema_desktop/features/movies/presentation/bloc/movies_event.dart';
import 'package:icinema_desktop/features/movies/presentation/pages/movies_page.dart';
import 'package:icinema_desktop/features/projections/presentation/pages/projections_page.dart';
import 'package:icinema_desktop/features/cinemas/presentation/pages/cinemas_page.dart';
import 'package:icinema_desktop/features/home/presentation/pages/home_page.dart';
import 'package:icinema_desktop/features/home/presentation/bloc/home_kpis_cubit.dart';
import 'package:icinema_desktop/features/reports/presentation/pages/reports_page.dart';
import 'package:icinema_desktop/features/reference/presentation/pages/admin_page.dart';
import 'package:icinema_desktop/features/reference/presentation/pages/countries_page.dart';
import 'package:icinema_desktop/features/reference/presentation/pages/cities_page.dart';
import 'package:icinema_desktop/features/reference/presentation/pages/genres_page.dart';
import 'package:icinema_desktop/features/reference/presentation/pages/directors_page.dart';
import 'package:icinema_desktop/features/reference/presentation/pages/actors_page.dart';

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

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: getIt<AuthService>().authState,
    redirect: (context, state) {
      final loggedIn = getIt<AuthService>().authState.value;
      final loggingIn = state.matchedLocation == '/login';

      if (!loggedIn && !loggingIn) {
        return '/login';
      }
      if (loggedIn && loggingIn) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => BlocProvider<LoginBloc>(
          create: (_) => getIt<LoginBloc>(),
          child: const LoginPage(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(currentLocation: state.uri.toString(), child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => _fadeTransitionPage(
              BlocProvider<HomeKpisCubit>(
                create: (_) => getIt<HomeKpisCubit>()..load(),
                child: const HomePage(),
              ),
              state,
            ),
          ),
          GoRoute(
            path: '/movies',
            pageBuilder: (context, state) => _fadeTransitionPage(
              BlocProvider<MoviesBloc>(
                create: (_) => getIt<MoviesBloc>()..add(LoadMovies()),
                child: const MoviesPage(),
              ),
              state,
            ),
          ),
          GoRoute(
            path: '/projections',
            pageBuilder: (context, state) => _fadeTransitionPage(
              const ProjectionsPage(),
              state,
            ),
          ),
          GoRoute(
            path: '/cinemas',
            pageBuilder: (context, state) => _fadeTransitionPage(
              const CinemasPage(),
              state,
            ),
          ),
          GoRoute(
            path: '/reports',
            pageBuilder: (context, state) => _fadeTransitionPage(
              const ReportsPage(),
              state,
            ),
          ),
          GoRoute(
            path: '/admin',
            pageBuilder: (context, state) => _fadeTransitionPage(
              const AdminPage(),
              state,
            ),
          ),
          GoRoute(
            path: '/admin/countries',
            pageBuilder: (context, state) => _fadeTransitionPage(
              const CountriesPage(),
              state,
            ),
          ),
          GoRoute(
            path: '/admin/cities',
            pageBuilder: (context, state) => _fadeTransitionPage(
              const CitiesPage(),
              state,
            ),
          ),
          GoRoute(
            path: '/admin/genres',
            pageBuilder: (context, state) => _fadeTransitionPage(
              const GenresPage(),
              state,
            ),
          ),
          GoRoute(
            path: '/admin/directors',
            pageBuilder: (context, state) => _fadeTransitionPage(
              const DirectorsPage(),
              state,
            ),
          ),
          GoRoute(
            path: '/admin/actors',
            pageBuilder: (context, state) => _fadeTransitionPage(
              const ActorsPage(),
              state,
            ),
          ),
        ],
      ),
    ],
  );
}
