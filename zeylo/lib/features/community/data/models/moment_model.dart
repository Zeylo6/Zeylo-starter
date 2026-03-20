import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/moment_entity.dart';

class MomentModel extends Moment {
  const MomentModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.userAvatar,
    required super.imageUrl,
    required super.createdAt,
    required super.expiresAt,
    super.caption,
    super.experienceId,
  });

  factory MomentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MomentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userAvatar: data['userAvatar'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      caption: data['caption'],
      experienceId: data['experienceId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'caption': caption,
      'experienceId': experienceId,
    };
  }

  static MomentModel fromEntity(Moment entity) {
    return MomentModel(
      id: entity.id,
      userId: entity.userId,
      userName: entity.userName,
      userAvatar: entity.userAvatar,
      imageUrl: entity.imageUrl,
      createdAt: entity.createdAt,
      expiresAt: entity.expiresAt,
      caption: entity.caption,
      experienceId: entity.experienceId,
    );
  }

  Moment toEntity() {
    return Moment(
      id: id,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      imageUrl: imageUrl,
      createdAt: createdAt,
      expiresAt: expiresAt,
      caption: caption,
      experienceId: experienceId,
    );
  }
}
