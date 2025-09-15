import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../layout/app_shell.dart';
import '../di/injection.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/bloc/home_cubit.dart';
import '../../features/movies/presentation/pages/movies_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';

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
              const MoviesPage(),
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
}
