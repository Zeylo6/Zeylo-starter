import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/post_entity.dart';

/// Model for Post data
class PostModel {
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

  PostModel({
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

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String,
      images: List<String>.from(json['images'] as List? ?? []),
      caption: json['caption'] as String,
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      tags: List<String>.from(json['tags'] as List? ?? []),
      experienceTag: json['experienceTag'] as String?,
    );
  }

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      userAvatar: data['userAvatar'] as String,
      images: List<String>.from(data['images'] as List? ?? []),
      caption: data['caption'] as String,
      likesCount: data['likesCount'] as int? ?? 0,
      commentsCount: data['commentsCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] as List? ?? []),
      experienceTag: data['experienceTag'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'images': images,
      'caption': caption,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
      'experienceTag': experienceTag,
    };
  }

  Post toEntity() {
    return Post(
      id: id,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      images: images,
      caption: caption,
      likesCount: likesCount,
      commentsCount: commentsCount,
      createdAt: createdAt,
      tags: tags,
      experienceTag: experienceTag,
    );
  }
}
