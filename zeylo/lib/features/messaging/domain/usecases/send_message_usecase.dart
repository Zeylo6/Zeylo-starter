import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/message_entity.dart';
import '../repositories/messaging_repository.dart';

/// Use case for sending messages
class SendMessageUseCase {
  final MessagingRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, MessageEntity>> call(
    String conversationId,
    String senderId,
    String text, {
    String messageType = 'text',
    String? imageUrl,
  }) async {
    return await repository.sendMessage(
      conversationId,
      senderId,
      text,
      messageType: messageType,
      imageUrl: imageUrl,
    );
  }
}
