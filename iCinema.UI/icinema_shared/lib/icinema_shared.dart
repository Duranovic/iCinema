/// Shared package for iCinema desktop and mobile applications
library icinema_shared;

// Core - Errors
export 'core/errors/app_exception.dart';
export 'core/errors/network_exception.dart';

// Core - Network
export 'core/network/api_client.dart';
export 'core/network/interceptors/auth_interceptor.dart';
export 'core/network/interceptors/error_interceptor.dart';

// Core - Constants
export 'core/constants/api_endpoints.dart';
export 'core/constants/app_constants.dart';

// Core - Utils
export 'core/utils/error_handler.dart';

// Data - Models
export 'data/models/common/paged_result.dart';
export 'data/models/user/user_me_model.dart';
export 'data/models/reservation/reservation_model.dart';
export 'data/models/reservation/ticket_model.dart';
export 'data/models/movie/movie_model.dart';
export 'data/models/movie/cast_member_model.dart';
export 'data/models/projection/projection_model.dart';

// Domain - Entities
export 'domain/entities/user_entity.dart';

