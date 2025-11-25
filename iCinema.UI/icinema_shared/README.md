# iCinema Shared Package

Shared code package for iCinema desktop and mobile applications.

## Structure

```
lib/
  core/
    errors/          # Common exception classes
    network/         # Base API client and interceptors
    constants/       # API endpoints and app constants
  data/
    models/          # Shared data models
  domain/
    entities/        # Shared domain entities
```

## Usage

Add to your `pubspec.yaml`:

```yaml
dependencies:
  icinema_shared:
    path: ../icinema_shared
```

Then import:

```dart
import 'package:icinema_shared/icinema_shared.dart';
```

## Models

- `PagedResult<T>` - Generic paginated result
- `UserMeModel` - Current user model
- `ReservationModel` - Reservation model
- `TicketModel` - Ticket model
- `UserEntity` - Domain user entity

## Network

- `ApiClient` - Base API client class
- `AuthInterceptor` - Authorization header interceptor
- `ErrorInterceptor` - Global error handling interceptor

## Constants

- `ApiEndpoints` - API endpoint constants
- `AppConstants` - Application-wide constants

## Errors

- `AppException` - Base exception
- `NetworkException` - Network-related exceptions
- `ValidationException` - Validation errors
- `BusinessRuleException` - Business rule violations

