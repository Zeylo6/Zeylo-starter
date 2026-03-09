import '../repositories/auth_repository.dart';

/// Use case for checking if the user's email has been verified via Firebase link
class VerifyEmailUseCase {
  final AuthRepository repository;

  const VerifyEmailUseCase(this.repository);

  /// Reload user and check emailVerified status
  Future<bool> call() async {
    return repository.checkEmailVerified();
  }
}
