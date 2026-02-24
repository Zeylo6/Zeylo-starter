import 'package:equatable/equatable.dart';

/// Entity representing a community post
class Post extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final List<String> images;
  final String caption;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final List<String> tags;
  final String? experienceTag;

  const Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.images,
    required this.caption,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
    required this.tags,
    this.experienceTag,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userAvatar,
        images,
        caption,
        likesCount,
        commentsCount,
        createdAt,
        tags,
        experienceTag,
      ];
}
