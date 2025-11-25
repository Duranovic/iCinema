/// API endpoint constants
class ApiEndpoints {
  // Auth endpoints
  static const String login = '/auth/login';
  static const String loginAdmin = '/auth/login-admin';
  static const String register = '/Auth/register';
  static const String logout = '/auth/logout';
  
  // User endpoints
  static const String users = '/users';
  static const String usersMe = '/users/me';
  static const String usersMeReservations = '/users/me/reservations';
  
  // Projections endpoints
  static const String projections = '/projections';
  static const String projectionsToday = '/projections/today';
  static const String projectionsUpcoming = '/projections/upcoming';
  
  // Movies endpoints
  static const String movies = '/movies';
  static const String moviesSearch = '/movies/search';
  static const String moviesRecommendations = '/movies/recommendations';
  
  // Reservations endpoints
  static const String reservations = '/reservations';
  
  // Notifications endpoints
  static const String notifications = '/notifications';
  
  // Validation endpoints
  static const String validation = '/validation';
  
  // Reference data endpoints
  static const String countries = '/countries';
  static const String cities = '/cities';
  static const String cinemas = '/cinemas';
  static const String halls = '/halls';
  static const String genres = '/genres';
  static const String directors = '/directors';
  static const String actors = '/actors';
  
  // Reports endpoints
  static const String reports = '/reports';
}

