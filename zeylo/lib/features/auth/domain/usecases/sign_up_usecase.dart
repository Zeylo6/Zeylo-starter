import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing up with email and password
class SignUpUseCase {
  /// The auth repository instance
  final AuthRepository repository;

  /// Creates a new SignUpUseCase instance
  const SignUpUseCase(this.repository);

  /// Execute the sign up operation
  ///
  /// Parameters:
  /// - [name]: User's full name
  /// - [email]: User's email address
  /// - [phone]: User's phone number
  /// - [password]: User's password
  ///
  /// Returns: The newly created user
  /// Throws: [Exception] if sign up fails
  Future<UserEntity> call({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    return repository.signUpWithEmail(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
  }
}
