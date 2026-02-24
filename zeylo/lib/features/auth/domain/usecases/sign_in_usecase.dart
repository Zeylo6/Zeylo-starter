import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with email and password
class SignInUseCase {
  /// The auth repository instance
  final AuthRepository repository;

  /// Creates a new SignInUseCase instance
  const SignInUseCase(this.repository);

  /// Execute the sign in operation
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  ///
  /// Returns: The authenticated user
  /// Throws: [Exception] if sign in fails
  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    return repository.signInWithEmail(
      email: email,
      password: password,
    );
  }
}
