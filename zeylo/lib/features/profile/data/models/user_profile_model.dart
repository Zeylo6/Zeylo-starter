import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../profile/domain/entities/user_profile_entity.dart';

/// User profile model for data layer with Firestore serialization
class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.name,
    super.email,
    super.phone,
    super.photoUrl,
    super.bio,
    super.followerCount = 0,
    super.followingCount = 0,
    super.postCount = 0,
    super.isVerified = false,
    super.isSuperhost = false,
    super.averageRating,
    super.ratingCount,
    required super.createdAt,
    super.updatedAt,
  });

  /// Create model from Firestore document
  factory UserProfileModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return UserProfileModel(
      id: doc.id,
      name: data['name'] as String? ?? data['displayName'] as String? ?? '',
      email: data['email'] as String?,
      phone: data['phone'] as String? ?? data['phoneNumber'] as String?,
      photoUrl: data['photoUrl'] as String?,
      bio: data['bio'] as String?,
      followerCount: data['followerCount'] as int? ?? data['followersCount'] as int? ?? 0,
      followingCount: data['followingCount'] as int? ?? 0,
      postCount: data['postCount'] as int? ?? data['postsCount'] as int? ?? 0,
      isVerified: data['isVerified'] as bool? ?? false,
      isSuperhost: data['isSuperhost'] as bool? ?? false,
      averageRating: (data['averageRating'] as num?)?.toDouble(),
      ratingCount: data['ratingCount'] as int?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert model to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'bio': bio,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'postCount': postCount,
      'isVerified': isVerified,
      'isSuperhost': isSuperhost,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Create a copy with modified fields
  UserProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? bio,
    int? followerCount,
    int? followingCount,
    int? postCount,
    bool? isVerified,
    bool? isSuperhost,
    double? averageRating,
    int? ratingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      postCount: postCount ?? this.postCount,
      isVerified: isVerified ?? this.isVerified,
      isSuperhost: isSuperhost ?? this.isSuperhost,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
