import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/router/app_router.dart';
import 'app/di/injection.dart';
import 'app/config/app_config.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/auth/presentation/bloc/reservations_cubit.dart';

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (cert, host, port) {
      // Trust local dev servers
      if (host == 'localhost' || host == '127.0.0.1') return true;
      return false;
    };
    return client;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AppConfig.allowInsecureCertificates) {
    HttpOverrides.global = DevHttpOverrides();
  }
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Defensive: ensure AuthCubit is registered (hot reload/init order safety)
    if (!getIt.isRegistered<AuthCubit>()) {
      getIt.registerLazySingleton<AuthCubit>(
        () => AuthCubit(getIt(), getIt()),
      );
    }
    // Defensive: ensure ReservationsCubit factory is registered (hot reload safety)
    if (!getIt.isRegistered<ReservationsCubit>(instanceName: null)) {
      // Register the factory with param if missing
      getIt.registerFactoryParam<ReservationsCubit, String, void>(
        (status, _) => ReservationsCubit(getIt(), status: status),
      );
    }
    final authCubit = getIt<AuthCubit>();
    authCubit.init();
    final router = buildRouter();
    
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
      ],
      child: MaterialApp.router(
      title: 'iCinema',
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFF1E1E1E),
          selectedItemColor: Colors.deepPurple[300],
          unselectedItemColor: Colors.grey[400],
          elevation: 16,
          type: BottomNavigationBarType.fixed,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('bs'),
        Locale('hr'),
        Locale('sr'),
      ],
    ),
    );
  }
}

