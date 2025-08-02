import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Allows injectable to register third-party types.
@module
abstract class NetworkModule {
  /// Registers a lazy singleton Dio for entire app.
  @lazySingleton
  Dio get dio => Dio(
    BaseOptions(
      baseUrl: 'https://localhost:7026', // adjust to your API
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );
}