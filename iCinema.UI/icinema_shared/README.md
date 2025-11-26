# iCinema Shared Package

Shared code library for iCinema desktop and mobile Flutter applications.

## Overview

This package contains common code shared between `icinema_desktop` and `icinema_mobile_client` applications, including:

- **Models** - Data transfer objects and domain entities
- **Network** - API client, interceptors, and error handling
- **Utilities** - Common helper functions and error handling

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  icinema_shared:
    path: ../icinema_shared
```

## Exports

### Core - Errors
- `AppException` - Base exception class
- `NetworkException` - Network-related exceptions (ConnectionException, ServerException, ClientException, UnauthorizedException, NotFoundException)

### Core - Network
- `ApiClient` - Base HTTP client using Dio
- `AuthInterceptor` - JWT token injection
- `ErrorInterceptor` - Error normalization

### Core - Constants
- `ApiEndpoints` - API endpoint paths
- `AppConstants` - Application-wide constants

### Core - Utils
- `ErrorHandler` - Centralized error handling with user-friendly messages

### Data - Models
- `PagedResult<T>` - Generic paginated response model
- `UserMeModel` - Current user profile
- `ReservationModel` - Reservation details
- `TicketModel` - Ticket information
- `MovieModel` - Movie details with cast and ratings
- `CastMemberModel` - Actor/role information
- `ProjectionModel` - Movie screening/projection

### Domain - Entities
- `UserEntity` - Domain user representation

## Usage

```dart
import 'package:icinema_shared/icinema_shared.dart';

// Use ErrorHandler for consistent error messages
try {
  await someApiCall();
} catch (e) {
  final message = ErrorHandler.getMessage(e);
  // Display user-friendly message
}

// Use shared models
final movie = MovieModel.fromJson(json);
final projection = ProjectionModel.fromJson(json);
```

## Architecture

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_endpoints.dart
│   │   └── app_constants.dart
│   ├── errors/
│   │   ├── app_exception.dart
│   │   └── network_exception.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       └── error_interceptor.dart
│   └── utils/
│       └── error_handler.dart
├── data/
│   └── models/
│       ├── common/
│       │   └── paged_result.dart
│       ├── movie/
│       │   ├── cast_member_model.dart
│       │   └── movie_model.dart
│       ├── projection/
│       │   └── projection_model.dart
│       ├── reservation/
│       │   ├── reservation_model.dart
│       │   └── ticket_model.dart
│       └── user/
│           └── user_me_model.dart
├── domain/
│   └── entities/
│       └── user_entity.dart
└── icinema_shared.dart
```

## Dependencies

- `dio` - HTTP client
- `equatable` - Value equality
- `get_it` - Dependency injection
- `shared_preferences` - Local storage
