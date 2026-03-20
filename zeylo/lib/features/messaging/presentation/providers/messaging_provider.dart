import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/messaging_datasource.dart';
import '../../data/repositories/messaging_repository_impl.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/set_typing_status_usecase.dart';

// Datasource provider
final messagingDatasourceProvider = Provider((ref) {
  return MessagingFirestoreDatasource(FirebaseFirestore.instance);
});

// Repository provider
final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  final datasource = ref.watch(messagingDatasourceProvider);
  return MessagingRepositoryImpl(datasource);
});

// Use case provider
final sendMessageUseCaseProvider = Provider((ref) {
  final repository = ref.watch(messagingRepositoryProvider);
  return SendMessageUseCase(repository);
});

// Set typing status use case provider
final setTypingStatusUseCaseProvider = Provider((ref) {
  final repository = ref.watch(messagingRepositoryProvider);
  return SetTypingStatusUseCase(repository);
});

// Conversations stream provider
final conversationsStreamProvider =
    StreamProvider.family<List<ConversationEntity>, String>(
  (ref, userId) {
    final repository = ref.watch(messagingRepositoryProvider);
    return repository.streamConversations(userId);
  },
);

// Individual conversation stream provider
final conversationStreamProvider =
    StreamProvider.family<ConversationEntity, String>(
  (ref, conversationId) {
    final repository = ref.watch(messagingRepositoryProvider);
    return repository.streamConversation(conversationId);
  },
);

// Messages stream provider
final messagesStreamProvider =
    StreamProvider.family<List<MessageEntity>, String>(
  (ref, conversationId) {
    final repository = ref.watch(messagingRepositoryProvider);
    return repository.streamMessages(conversationId);
  },
);

// Send message provider
final sendMessageProvider = FutureProvider.family<
    void,
    (String conversationId, String senderId, String text, String messageType, String? imageUrl)>(
  (ref, params) async {
    final repository = ref.watch(messagingRepositoryProvider);
    final (conversationId, senderId, text, messageType, imageUrl) = params;

    final result = await repository.sendMessage(
      conversationId,
      senderId,
      text,
      messageType: messageType,
      imageUrl: imageUrl,
    );
    result.fold(
      (failure) => throw failure.message,
      (_) {
        // Invalidate messages stream
        ref.invalidate(messagesStreamProvider(conversationId));
      },
    );
  },
);

// Set typing status provider
final setTypingStatusProvider = FutureProvider.family<
    void,
    (String conversationId, String userId, bool isTyping)>(
  (ref, params) async {
    final useCase = ref.watch(setTypingStatusUseCaseProvider);
    final (conversationId, userId, isTyping) = params;

    final result = await useCase(conversationId, userId, isTyping);
    result.fold(
      (failure) => throw failure.message,
      (_) => null,
    );
  },
);

// Get or create conversation provider
final getOrCreateConversationProvider = FutureProvider.family<
    ConversationEntity,
    (String userId, String otherUserId)>(
  (ref, params) async {
    final repository = ref.watch(messagingRepositoryProvider);
    final (userId, otherUserId) = params;

    final result =
        await repository.getOrCreateConversation(userId, otherUserId);
    return result.fold(
      (failure) => throw failure.message,
      (conversation) => conversation,
    );
  },
);
