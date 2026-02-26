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
    super.message = 'Server error occurred. Please try again later.',
  });
}

/// Failure when there's an issue with cached data
class CacheFailure extends Failure {
  CacheFailure({
    super.message = 'Cache error occurred. Please refresh the app.',
  });
}

/// Failure when there's a network connectivity issue
class NetworkFailure extends Failure {
  NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
  });
}

/// Failure when authentication fails
class AuthFailure extends Failure {
  final String code;

  AuthFailure({
    super.message = 'Authentication failed. Please try again.',
    this.code = 'AUTH_ERROR',
  });
}

/// Failure when form validation fails
class ValidationFailure extends Failure {
  final String field;

  ValidationFailure({
    required super.message,
    this.field = '',
  });
}

/// Failure specific to Firebase operations
class FirebaseFailure extends Failure {
  final String code;

  FirebaseFailure({
    super.message = 'Firebase error occurred.',
    this.code = 'FIREBASE_ERROR',
  });
}

/// Failure when an operation is not found (404)
class NotFoundFailure extends Failure {
  NotFoundFailure({
    super.message = 'Resource not found.',
  });
}

/// Failure when the user is unauthorized (401)
class UnauthorizedFailure extends Failure {
  UnauthorizedFailure({
    super.message = 'You are not authorized to perform this action.',
  });
}

/// Failure when the user is forbidden (403)
class ForbiddenFailure extends Failure {
  ForbiddenFailure({
    super.message = 'You do not have permission to access this resource.',
  });
}

/// Failure for conflict errors (409)
class ConflictFailure extends Failure {
  ConflictFailure({
    super.message = 'This action conflicts with existing data.',
  });
}

/// Failure for timeout errors
class TimeoutFailure extends Failure {
  TimeoutFailure({
    super.message = 'Request timed out. Please try again.',
  });
}

/// Failure for unknown/unexpected errors
class UnknownFailure extends Failure {
  final dynamic error;
  final StackTrace? stackTrace;

  UnknownFailure({
    super.message = 'An unexpected error occurred.',
    this.error,
    this.stackTrace,
  });
}
