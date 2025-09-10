import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icinema_desktop/app/di/injection.dart';
import 'package:icinema_desktop/app/layout/app_shell.dart';
import 'package:icinema_desktop/features/auth/presentation/blocs/login/login_bloc.dart';
import 'package:icinema_desktop/features/auth/presentation/pages/login_page.dart';
import 'package:icinema_desktop/features/movies/presentation/bloc/movies_bloc.dart';
import 'package:icinema_desktop/features/movies/presentation/bloc/movies_event.dart';
import 'package:icinema_desktop/features/movies/presentation/pages/movies_page.dart';
import 'package:icinema_desktop/features/projections/presentation/pages/projections_page.dart';
import 'package:icinema_desktop/features/cinemas/presentation/pages/cinemas_page.dart';
import 'package:icinema_desktop/pages/halls_page.dart';
import 'package:icinema_desktop/pages/home_page.dart';
import 'package:icinema_desktop/pages/profile_page.dart';
import 'package:icinema_desktop/features/reports/presentation/pages/reports_page.dart';
import 'package:icinema_desktop/pages/users_page.dart';

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

final GoRouter router = GoRouter(
  initialLocation: '/home',
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
            const HomePage(),
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
          path: '/halls',
          pageBuilder: (context, state) => _fadeTransitionPage(
            const HallsPage(),
            state,
          ),
        ),
        GoRoute(
          path: '/users',
          pageBuilder: (context, state) => _fadeTransitionPage(
            const UsersPage(),
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
          path: '/profile',
          pageBuilder: (context, state) => _fadeTransitionPage(
            const ProfilePage(),
            state,
          ),
        ),
      ],
    ),
  ],
);
