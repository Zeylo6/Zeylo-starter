import 'package:equatable/equatable.dart';
import 'message_entity.dart';

/// Conversation entity for domain layer
class ConversationEntity extends Equatable {
  final String id;
  final List<String> participants;
  final MessageEntity? lastMessage;
  final DateTime lastMessageAt;
  final DateTime createdAt;

  const ConversationEntity({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.lastMessageAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        participants,
        lastMessage,
        lastMessageAt,
        createdAt,
      ];

  ConversationEntity copyWith({
    String? id,
    List<String>? participants,
    MessageEntity? lastMessage,
    DateTime? lastMessageAt,
    DateTime? createdAt,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
