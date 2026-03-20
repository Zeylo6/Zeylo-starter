import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import 'message_model.dart';

/// Conversation model for data layer
class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.participants,
    super.typingUsers = const [],
    super.lastMessage,
    required super.lastMessageAt,
    required super.createdAt,
  });

  factory ConversationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final lastMessageData = data['lastMessage'] as Map<String, dynamic>?;

    return ConversationModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] as List? ?? []),
      typingUsers: List<String>.from(data['typingUsers'] as List? ?? []),
      lastMessage: lastMessageData != null
          ? MessageModel.fromMap(lastMessageData)
          : null,
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'typingUsers': typingUsers,
      'lastMessage': lastMessage != null
          ? (lastMessage as MessageModel?)?.toMap()
          : null,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  ConversationModel copyWith({
    String? id,
    List<String>? participants,
    List<String>? typingUsers,
    MessageEntity? lastMessage,
    DateTime? lastMessageAt,
    DateTime? createdAt,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      typingUsers: typingUsers ?? this.typingUsers,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
