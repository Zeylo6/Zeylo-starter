import '../repositories/auth_repository.dart';

/// Use case for verifying email with verification code
class VerifyEmailUseCase {
  /// The auth repository instance
  final AuthRepository repository;

  /// Creates a new VerifyEmailUseCase instance
  const VerifyEmailUseCase(this.repository);

  /// Execute the email verification operation
  ///
  /// Parameters:
  /// - [code]: The verification code sent to the user's email
  ///
  /// Returns: true if verification succeeds, false otherwise
  /// Throws: [Exception] if verification fails
  Future<bool> call(String code) async {
    return repository.verifyEmail(code);
  }
}
