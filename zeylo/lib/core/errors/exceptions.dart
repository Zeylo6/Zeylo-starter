/// Custom exceptions used throughout the Zeylo application
/// These are caught and converted to Failures for UI handling
library;

/// Base exception class for all custom exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => message;
}

/// Exception thrown when a server error occurs
class ServerException extends AppException {
  ServerException({
    super.message = 'Server error occurred',
    super.code,
    super.originalException,
  });
}

/// Exception thrown when there's a cache-related error
class CacheException extends AppException {
  CacheException({
    super.message = 'Cache error occurred',
    super.code,
    super.originalException,
  });
}

/// Exception thrown when there's a network connectivity issue
class NetworkException extends AppException {
  NetworkException({
    super.message = 'Network error occurred',
    super.code,
    super.originalException,
  });
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  AuthException({
    super.message = 'Authentication failed',
    super.code,
    super.originalException,
  });
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  final String? field;

  ValidationException({
    required super.message,
    this.field,
    super.code,
    super.originalException,
  });
}

/// Exception thrown for Firebase-specific errors
class FirebaseException extends AppException {
  FirebaseException({
    super.message = 'Firebase error occurred',
    super.code,
    super.originalException,
  });
}

/// Exception thrown when a resource is not found
class NotFoundException extends AppException {
  NotFoundException({
    super.message = 'Resource not found',
    super.code,
    super.originalException,
  });
}

/// Exception thrown when an operation times out
class TimeoutException extends AppException {
  TimeoutException({
    super.message = 'Request timed out',
    super.code,
    super.originalException,
  });
}

/// Exception thrown when an operation is unauthorized
class UnauthorizedException extends AppException {
  UnauthorizedException({
    super.message = 'Unauthorized access',
    super.code,
    super.originalException,
  });
}

/// Exception thrown when there's a permission/access issue
class PermissionException extends AppException {
  PermissionException({
    super.message = 'Permission denied',
    super.code,
    super.originalException,
  });
}

/// Exception thrown for state-related errors
class StateException extends AppException {
  StateException({
    super.message = 'Invalid state',
    super.code,
    super.originalException,
  });
}

/// Generic exception for unknown errors
class UnknownException extends AppException {
  UnknownException({
    super.message = 'An unknown error occurred',
    super.code,
    super.originalException,
  });
}
