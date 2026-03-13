import '../repositories/auth_repository.dart';

/// Use case for sending a password reset email
class ResetPasswordUseCase {
  final AuthRepository repository;

  const ResetPasswordUseCase(this.repository);

  Future<void> call(String email) async {
    return repository.resetPassword(email);
  }
}
