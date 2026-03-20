import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/messaging_repository.dart';

class SetTypingStatusUseCase {
  final MessagingRepository _repository;

  SetTypingStatusUseCase(this._repository);

  Future<Either<Failure, void>> call(
    String conversationId,
    String userId,
    bool isTyping,
  ) {
    return _repository.setTypingStatus(conversationId, userId, isTyping);
  }
}
