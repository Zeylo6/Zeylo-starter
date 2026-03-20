import 'package:equatable/equatable.dart';

/// Message entity for domain layer
class MessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final String messageType; // 'text' or 'image'
  final String? imageUrl;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    this.messageType = 'text',
    this.imageUrl,
    required this.createdAt,
    this.isRead = false,
    this.readAt,
  });

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        text,
        messageType,
        imageUrl,
        createdAt,
        isRead,
        readAt,
      ];

  MessageEntity copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? text,
    String? messageType,
    String? imageUrl,
    DateTime? createdAt,
    bool? isRead,
    DateTime? readAt,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      messageType: messageType ?? this.messageType,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }
}
