class AppConfig {
  // Configure via --dart-define=API_BASE_URL=https://<host>:<port>
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://localhost:7026',
  );

  // Dev only: set via --dart-define=ALLOW_INSECURE_CERT=true to bypass cert checks
  static const bool allowInsecureCertificates = bool.fromEnvironment(
    'ALLOW_INSECURE_CERT',
    defaultValue: true,
  );
}
