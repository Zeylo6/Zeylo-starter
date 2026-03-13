import '../repositories/auth_repository.dart';

/// Use case for sending Firebase email verification link
class SendVerificationEmailUseCase {
  final AuthRepository repository;

  const SendVerificationEmailUseCase(this.repository);

  Future<void> call() async {
    return repository.sendVerificationEmail();
  }
}
