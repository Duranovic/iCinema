/// Base exception class for application errors
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Exception for validation errors
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception for business rule violations
class BusinessRuleException extends AppException {
  const BusinessRuleException({
    required super.message,
    super.code,
    super.originalError,
  });
}

