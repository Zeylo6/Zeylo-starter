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
    super.isHostVerified = false,
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

    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      return DateTime.now();
    }

    return UserProfileModel(
      id: doc.id,
      name: data['name'] as String? ?? data['displayName'] as String? ?? '',
      email: data['email'] as String?,
      phone: data['phone'] as String? ?? data['phoneNumber'] as String?,
      photoUrl: data['photoUrl'] as String?,
      bio: data['bio'] as String?,
      followerCount:
          data['followerCount'] as int? ?? data['followersCount'] as int? ?? 0,
      followingCount: data['followingCount'] as int? ?? 0,
      postCount: data['postCount'] as int? ?? data['postsCount'] as int? ?? 0,
      isVerified: data['isVerified'] as bool? ?? false,
      isHostVerified: data['hostVerificationStatus'] == 'verified',
      isSuperhost: data['isSuperhost'] as bool? ?? false,
      averageRating: (data['stats']?['averageRating'] as num?)?.toDouble() ??
          (data['averageRating'] as num?)?.toDouble(),
      ratingCount: (data['stats']?['totalReviews'] as num?)?.toInt() ??
          data['ratingCount'] as int? ??
          0,
      createdAt: parseDate(data['createdAt']),
      updatedAt:
          data['updatedAt'] != null ? parseDate(data['updatedAt']) : null,
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
      'hostVerificationStatus': isHostVerified ? 'verified' : 'unverified',
      'isSuperhost': isSuperhost,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Create a copy with modified fields
  @override
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
    bool? isHostVerified,
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
      isHostVerified: isHostVerified ?? this.isHostVerified,
      isSuperhost: isSuperhost ?? this.isSuperhost,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
