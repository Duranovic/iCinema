class AppConfig {
  // Configure via --dart-define=API_BASE_URL=http://<host>:<port>
  // For Android Emulator use: http://10.0.2.2:5218
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5218',
  );

  // Dev only: set via --dart-define=ALLOW_INSECURE_CERT=true to bypass cert checks
  static const bool allowInsecureCertificates = bool.fromEnvironment(
    'ALLOW_INSECURE_CERT',
    defaultValue: true,
  );
}
