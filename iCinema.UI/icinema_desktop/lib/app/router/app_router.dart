import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icinema_desktop/app/di/injection.dart';
import 'package:icinema_desktop/app/layout/app_shell.dart';
import 'package:icinema_desktop/features/auth/presentation/blocs/login/login_bloc.dart';
import 'package:icinema_desktop/features/auth/presentation/pages/login_page.dart';
import 'package:icinema_desktop/pages/halls_page.dart';
import 'package:icinema_desktop/pages/home_page.dart';
import 'package:icinema_desktop/pages/movies_page.dart';
import 'package:icinema_desktop/pages/profile_page.dart';
import 'package:icinema_desktop/pages/projections_page.dart';
import 'package:icinema_desktop/pages/reports_page.dart';
import 'package:icinema_desktop/pages/users_page.dart';

final GoRouter router = GoRouter(initialLocation: '/home', routes: [
  GoRoute(
      path: '/login',
      builder: (context, state) => BlocProvider<LoginBloc>(
            create: (_) => getIt<LoginBloc>(),
            child: const LoginPage(),
          )),
  ShellRoute(
      builder: (context, state, child) =>
          AppShell(currentLocation: state.uri.toString(), child: child),
      routes: [
        GoRoute(
            path: '/home',
            builder: (context, state) {
              return const HomePage();
            }),
        GoRoute(
            path: '/movies',
            builder: (context, state) {
              return const MoviesPage();
            }),
        GoRoute(
            path: '/projections',
            builder: (context, state) {
              return const ProjectionsPage();
            }),
        GoRoute(
            path: '/halls',
            builder: (context, state) {
              return const HallsPage();
            }),
        GoRoute(
            path: '/users',
            builder: (builderContext, state) {
              return const UsersPage();
            }),
        GoRoute(
            path: '/reports',
            builder: (context, state) {
              return const ReportsPage();
            }),
        GoRoute(
            path: '/profile',
            builder: (context, state) {
              return const ProfilePage();
            })
      ])
]);
