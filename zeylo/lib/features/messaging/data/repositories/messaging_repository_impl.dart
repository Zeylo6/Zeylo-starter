import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../datasources/messaging_datasource.dart';

/// Implementation of MessagingRepository
class MessagingRepositoryImpl implements MessagingRepository {
  final MessagingDatasource _datasource;

  MessagingRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<ConversationEntity>>> getConversations(
    String userId,
  ) async {
    try {
      final conversations = await _datasource.getConversations(userId);
      return Right(conversations);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String conversationId,
  ) async {
    try {
      final messages = await _datasource.getMessages(conversationId);
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage(
    String conversationId,
    String senderId,
    String text, {
    String messageType = 'text',
    String? imageUrl,
  }) async {
    try {
      final message = await _datasource.sendMessage(
        conversationId,
        senderId,
        text,
        messageType: messageType,
        imageUrl: imageUrl,
      );
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setTypingStatus(
    String conversationId,
    String userId,
    bool isTyping,
  ) async {
    try {
      await _datasource.setTypingStatus(conversationId, userId, isTyping);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markMessageAsRead(
    String conversationId,
    String messageId,
  ) async {
    try {
      await _datasource.markMessageAsRead(conversationId, messageId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> getOrCreateConversation(
    String userId,
    String otherUserId,
  ) async {
    try {
      final conversation =
          await _datasource.getOrCreateConversation(userId, otherUserId);
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<MessageEntity>> streamMessages(String conversationId) {
    return _datasource.streamMessages(conversationId);
  }

  @override
  Stream<List<ConversationEntity>> streamConversations(String userId) {
    return _datasource.streamConversations(userId);
  }
}
