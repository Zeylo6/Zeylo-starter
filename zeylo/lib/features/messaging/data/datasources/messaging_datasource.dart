import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Abstract datasource for messaging operations
abstract class MessagingDatasource {
  /// Get all conversations for a user
  Future<List<ConversationModel>> getConversations(String userId);

  /// Get messages for a conversation
  Future<List<MessageModel>> getMessages(String conversationId);

  /// Send a message
  Future<MessageModel> sendMessage(
    String conversationId,
    String senderId,
    String text, {
    String messageType = 'text',
    String? imageUrl,
  });

  /// Mark message as read
  Future<void> markMessageAsRead(String conversationId, String messageId);

  /// Get or create conversation with a user
  Future<ConversationModel> getOrCreateConversation(
    String userId,
    String otherUserId,
  );

  /// Set typing status
  Future<void> setTypingStatus(String conversationId, String userId, bool isTyping);

  /// Stream messages for a conversation
  Stream<List<MessageModel>> streamMessages(String conversationId);

  /// Stream conversations for a user
  Stream<List<ConversationModel>> streamConversations(String userId);
}

/// Firestore implementation of messaging datasource
class MessagingFirestoreDatasource implements MessagingDatasource {
  final FirebaseFirestore _firestore;

  MessagingFirestoreDatasource(this._firestore);

  static const String _conversationsCollection = 'conversations';
  static const String _messagesCollection = 'messages';

  @override
  Future<List<ConversationModel>> getConversations(String userId) async {
    final snapshot = await _firestore
        .collection(_conversationsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) =>
            ConversationModel.fromFirestore(
                doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    final snapshot = await _firestore
        .collection(_conversationsCollection)
        .doc(conversationId)
        .collection(_messagesCollection)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) =>
            MessageModel.fromFirestore(
                doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }

  @override
  Future<MessageModel> sendMessage(
    String conversationId,
    String senderId,
    String text, {
    String messageType = 'text',
    String? imageUrl,
  }) async {
    final messageRef = _firestore
        .collection(_conversationsCollection)
        .doc(conversationId)
        .collection(_messagesCollection)
        .doc();

    final message = MessageModel(
      id: messageRef.id,
      conversationId: conversationId,
      senderId: senderId,
      text: text,
      messageType: messageType,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
      isRead: false,
    );

    await messageRef.set(message.toFirestore());

    // Update conversation's last message
    await _firestore
        .collection(_conversationsCollection)
        .doc(conversationId)
        .update({
          'lastMessage': message.toMap(),
          'lastMessageAt': Timestamp.fromDate(DateTime.now()),
        });

    return message;
  }

  @override
  Future<void> markMessageAsRead(
    String conversationId,
    String messageId,
  ) async {
    await _firestore
        .collection(_conversationsCollection)
        .doc(conversationId)
        .collection(_messagesCollection)
        .doc(messageId)
        .update({
          'isRead': true,
          'readAt': Timestamp.fromDate(DateTime.now()),
        });
  }

  @override
  Future<ConversationModel> getOrCreateConversation(
    String userId,
    String otherUserId,
  ) async {
    // Check if conversation already exists
    final existingSnapshot = await _firestore
        .collection(_conversationsCollection)
        .where('participants', arrayContains: userId)
        .get();

    for (final doc in existingSnapshot.docs) {
      final participants = List<String>.from(doc['participants'] as List? ?? []);
      if (participants.contains(otherUserId)) {
        return ConversationModel.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>);
      }
    }

    // Create new conversation
    final conversationRef =
        _firestore.collection(_conversationsCollection).doc();

    final conversation = ConversationModel(
      id: conversationRef.id,
      participants: [userId, otherUserId],
      typingUsers: const [],
      lastMessageAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await conversationRef.set(conversation.toFirestore());

    return conversation;
  }

  @override
  Future<void> setTypingStatus(String conversationId, String userId, bool isTyping) async {
    final docRef = _firestore.collection(_conversationsCollection).doc(conversationId);
    
    if (isTyping) {
      await docRef.update({
        'typingUsers': FieldValue.arrayUnion([userId])
      });
    } else {
      await docRef.update({
        'typingUsers': FieldValue.arrayRemove([userId])
      });
    }
  }

  @override
  Stream<List<MessageModel>> streamMessages(String conversationId) {
    return _firestore
        .collection(_conversationsCollection)
        .doc(conversationId)
        .collection(_messagesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MessageModel.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>))
              .toList();
        });
  }

  @override
  Stream<List<ConversationModel>> streamConversations(String userId) {
    return _firestore
        .collection(_conversationsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ConversationModel.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>))
              .toList();
        });
  }
}
