import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/messaging_datasource.dart';
import '../../data/repositories/messaging_repository_impl.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../../domain/usecases/send_message_usecase.dart';

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

// Conversations stream provider
final conversationsStreamProvider =
    StreamProvider.family<List<ConversationEntity>, String>(
  (ref, userId) {
    final repository = ref.watch(messagingRepositoryProvider);
    return repository.streamConversations(userId);
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
    (String conversationId, String senderId, String text)>(
  (ref, params) async {
    final repository = ref.watch(messagingRepositoryProvider);
    final (conversationId, senderId, text) = params;

    final result = await repository.sendMessage(conversationId, senderId, text);
    result.fold(
      (failure) => throw failure.message,
      (_) {
        // Invalidate messages stream
        ref.invalidate(messagesStreamProvider(conversationId));
      },
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
