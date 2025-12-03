import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'app/di/injection.dart';
import 'app/router/app_router.dart';

import 'package:flutter/foundation.dart'; // Import for kDebugMode

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    // ONLY trust self-signed certs in debug mode
    if (kDebugMode) {
      client.badCertificateCallback = (cert, host, port) => true;
    }
    return client;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable self-signed certificates ONLY for development/debug builds
  if (kDebugMode) {
    HttpOverrides.global = DevHttpOverrides();
  }
  
  // Configure window size constraints
  await windowManager.ensureInitialized();
  
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1400, 900), // Initial size
    minimumSize: Size(1200, 800), // Minimum size - user cannot resize smaller
    maximumSize: Size(2560, 1440), // Maximum size - user cannot resize larger
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setTitle('iCinema');
    await windowManager.show();
    await windowManager.focus();
  });
  
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'iCinema',
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
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
    );
  }
}
