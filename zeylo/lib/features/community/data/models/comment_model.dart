import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/comment_entity.dart';

/// Model representing a comment on a post
class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      return DateTime.now();
    }

    return CommentModel(
      id: doc.id,
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      userAvatar: data['userAvatar'] as String,
      text: data['text'] as String,
      createdAt: parseDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Comment toEntity() {
    return Comment(
      id: id,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      text: text,
      createdAt: createdAt,
    );
  }
}
