import 'package:equatable/equatable.dart';

/// Entity representing a comment on a community post
class Comment extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String text;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.text,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, userName, userAvatar, text, createdAt];
}
