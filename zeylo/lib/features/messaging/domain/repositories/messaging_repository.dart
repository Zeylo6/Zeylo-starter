import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

/// Abstract repository for messaging operations
abstract class MessagingRepository {
  /// Get all conversations for a user
  Future<Either<Failure, List<ConversationEntity>>> getConversations(
    String userId,
  );

  /// Get messages for a conversation
  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String conversationId,
  );

  /// Send a message
  Future<Either<Failure, MessageEntity>> sendMessage(
    String conversationId,
    String senderId,
    String text,
  );

  /// Mark message as read
  Future<Either<Failure, void>> markMessageAsRead(
    String conversationId,
    String messageId,
  );

  /// Get or create conversation with a user
  Future<Either<Failure, ConversationEntity>> getOrCreateConversation(
    String userId,
    String otherUserId,
  );

  /// Stream messages for a conversation
  Stream<List<MessageEntity>> streamMessages(String conversationId);

  /// Stream conversations for a user
  Stream<List<ConversationEntity>> streamConversations(String userId);
}
