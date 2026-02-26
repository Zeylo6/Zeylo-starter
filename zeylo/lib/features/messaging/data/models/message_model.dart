import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message_entity.dart';

/// Message model for data layer
class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.text,
    required super.createdAt,
    super.isRead = false,
    super.readAt,
  });

  factory MessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return MessageModel(
      id: doc.id,
      conversationId: data['conversationId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
    );
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String? ?? '',
      conversationId: map['conversationId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] as bool? ?? false,
      readAt: (map['readAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  @override
  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? text,
    DateTime? createdAt,
    bool? isRead,
    DateTime? readAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }
}
