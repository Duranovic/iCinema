/// Application-wide constants
class AppConstants {
  // Pagination defaults
  static const int defaultPageSize = 20;
  static const int defaultPage = 1;
  
  // Timeouts
  static const Duration defaultConnectTimeout = Duration(seconds: 30);
  static const Duration defaultReceiveTimeout = Duration(seconds: 30);
  
  // Storage keys
  static const String authTokenKey = 'auth_token';
  static const String authExpiryKey = 'auth_expiry';
  static const String authFullNameKey = 'auth_full_name';
  static const String authEmailKey = 'auth_email';
  
  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-ddTHH:mm:ss';
  static const String timeFormat = 'HH:mm';
}

