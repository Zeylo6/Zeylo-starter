/// Base failure class for error handling across the application
/// Follows the BLoC pattern for consistent error handling
abstract class Failure {
  final String message;

  Failure({required this.message});

  @override
  String toString() => message;
}

/// Failure when an error occurs on the server
class ServerFailure extends Failure {
  ServerFailure({
    String message = 'Server error occurred. Please try again later.',
  }) : super(message: message);
}

/// Failure when there's an issue with cached data
class CacheFailure extends Failure {
  CacheFailure({
    String message = 'Cache error occurred. Please refresh the app.',
  }) : super(message: message);
}

/// Failure when there's a network connectivity issue
class NetworkFailure extends Failure {
  NetworkFailure({
    String message = 'No internet connection. Please check your network.',
  }) : super(message: message);
}

/// Failure when authentication fails
class AuthFailure extends Failure {
  final String code;

  AuthFailure({
    String message = 'Authentication failed. Please try again.',
    this.code = 'AUTH_ERROR',
  }) : super(message: message);
}

/// Failure when form validation fails
class ValidationFailure extends Failure {
  final String field;

  ValidationFailure({
    required String message,
    this.field = '',
  }) : super(message: message);
}

/// Failure specific to Firebase operations
class FirebaseFailure extends Failure {
  final String code;

  FirebaseFailure({
    String message = 'Firebase error occurred.',
    this.code = 'FIREBASE_ERROR',
  }) : super(message: message);
}

/// Failure when an operation is not found (404)
class NotFoundFailure extends Failure {
  NotFoundFailure({
    String message = 'Resource not found.',
  }) : super(message: message);
}

/// Failure when the user is unauthorized (401)
class UnauthorizedFailure extends Failure {
  UnauthorizedFailure({
    String message = 'You are not authorized to perform this action.',
  }) : super(message: message);
}

/// Failure when the user is forbidden (403)
class ForbiddenFailure extends Failure {
  ForbiddenFailure({
    String message = 'You do not have permission to access this resource.',
  }) : super(message: message);
}

/// Failure for conflict errors (409)
class ConflictFailure extends Failure {
  ConflictFailure({
    String message = 'This action conflicts with existing data.',
  }) : super(message: message);
}

/// Failure for timeout errors
class TimeoutFailure extends Failure {
  TimeoutFailure({
    String message = 'Request timed out. Please try again.',
  }) : super(message: message);
}

/// Failure for unknown/unexpected errors
class UnknownFailure extends Failure {
  final dynamic error;
  final StackTrace? stackTrace;

  UnknownFailure({
    String message = 'An unexpected error occurred.',
    this.error,
    this.stackTrace,
  }) : super(message: message);
}
