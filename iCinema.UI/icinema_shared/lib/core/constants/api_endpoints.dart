/// API endpoint constants
/// All API endpoints should be defined here to ensure consistency and easy maintenance.
class ApiEndpoints {
  // Auth endpoints
  static const String login = '/auth/login';
  static const String loginAdmin = '/auth/login-admin';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  
  // User endpoints
  static const String users = '/users';
  static const String usersMe = '/users/me';
  static const String usersMeReservations = '/users/me/reservations';
  
  // Projections endpoints
  static const String projections = '/projections';
  static const String projectionsToday = '/projections/today';
  static const String projectionsUpcoming = '/projections/upcoming';
  static String projectionSeatMap(String id) => '/projections/$id/seat-map';
  
  // Movies endpoints
  static const String movies = '/movies';
  static const String moviesSearch = '/movies/search';
  static const String moviesRecommendations = '/movies/recommendations';
  static String movieById(String id) => '/movies/$id';
  static String movieMyRating(String id) => '/movies/$id/my-rating';
  static String movieRating(String id) => '/movies/$id/rating';
  static String movieCanRate(String id) => '/movies/$id/can-rate';
  static String movieCast(String id) => '/movies/$id/cast';
  static String movieCastItem(String movieId, String actorId) => '/movies/$movieId/cast/$actorId';
  
  // Reservations endpoints
  static const String reservations = '/reservations';
  static String reservationById(String id) => '/reservations/$id';
  static String reservationCancel(String id) => '/reservations/$id/cancel';
  static String reservationTickets(String reservationId) => '/users/me/reservations/$reservationId/tickets';
  
  // Notifications endpoints
  static const String notifications = '/notifications';
  static const String notificationsMy = '/notifications/my';
  static String notificationRead(String id) => '/notifications/$id/read';
  static String notificationById(String id) => '/notifications/$id';
  
  // Tickets endpoints
  static String ticketQr(String id) => '/tickets/$id/qr';
  static const String ticketsValidate = '/tickets/validate';
  
  // Metadata endpoints
  static const String metadataAgeRatings = '/metadata/age-ratings';
  static const String metadataDirectors = '/metadata/directors';
  
  // Reference data endpoints
  static const String countries = '/countries';
  static const String cities = '/cities';
  static const String cinemas = '/cinemas';
  static const String halls = '/halls';
  static const String genres = '/genres';
  static const String directors = '/directors';
  static const String actors = '/actors';
  static const String actorsItems = '/actors/items';
  
  // Reports endpoints
  static const String reports = '/reports';
  static const String reportsGenerate = '/reports/generate';
}

