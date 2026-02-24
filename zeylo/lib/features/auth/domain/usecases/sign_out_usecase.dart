import '../repositories/auth_repository.dart';

/// Use case for signing out the current user
class SignOutUseCase {
  /// The auth repository instance
  final AuthRepository repository;

  /// Creates a new SignOutUseCase instance
  const SignOutUseCase(this.repository);

  /// Execute the sign out operation
  ///
  /// Clears the user's session and authentication tokens
  /// Throws: [Exception] if sign out fails
  Future<void> call() async {
    return repository.signOut();
  }
}
