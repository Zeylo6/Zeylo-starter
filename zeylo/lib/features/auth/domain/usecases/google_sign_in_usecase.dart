import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with Google
class GoogleSignInUseCase {
  /// The auth repository instance
  final AuthRepository repository;

  /// Creates a new GoogleSignInUseCase instance
  const GoogleSignInUseCase(this.repository);

  /// Execute the Google sign in operation
  ///
  /// Opens the Google authentication flow and authenticates the user
  ///
  /// Returns: The authenticated user
  /// Throws: [Exception] if sign in fails
  Future<UserEntity> call() async {
    return repository.signInWithGoogle();
  }
}
