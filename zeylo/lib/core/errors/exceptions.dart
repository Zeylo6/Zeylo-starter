/// Custom exceptions used throughout the Zeylo application
/// These are caught and converted to Failures for UI handling

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
    String message = 'Server error occurred',
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );
}

/// Exception thrown when there's a cache-related error
class CacheException extends AppException {
  CacheException({
    String message = 'Cache error occurred',
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );
}

/// Exception thrown when there's a network connectivity issue
class NetworkException extends AppException {
  NetworkException({
    String message = 'Network error occurred',
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  AuthException({
    String message = 'Authentication failed',
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  final String? field;

  ValidationException({
    required String message,
    this.field,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );
}

/// Exception thrown for Firebase-specific errors
class FirebaseException extends AppException {
  FirebaseException({
    String message = 'Firebase error occurred',
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );
}

/// Exception thrown when a resource is not found
class NotFoundException extends AppException {
  NotFoundException({
    String message = 'Resource not found',
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );
}

/// Exception thrown when an operation times out
class TimeoutException extends AppException {
  TimeoutException({
    String message = 'Request timed out',
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );
}

/// Exception thrown when an operation is unauthorized
class UnauthorizedException extends AppException {
  UnauthorizedException({
    String message = 'Unauthorized access',
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );
}

/// Exception thrown when there's a permission/access issue
class PermissionException extends AppException {
  PermissionException({
    String message = 'Permission denied',
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );
}

/// Exception thrown for state-related errors
class StateException extends AppException {
  StateException({
    String message = 'Invalid state',
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );
}

/// Generic exception for unknown errors
class UnknownException extends AppException {
  UnknownException({
    String message = 'An unknown error occurred',
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );
}
