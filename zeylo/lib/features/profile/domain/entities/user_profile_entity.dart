import 'package:equatable/equatable.dart';

/// User profile entity for domain layer
class UserProfileEntity extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? photoUrl;
  final String? bio;
  final int followerCount;
  final int followingCount;
  final int postCount;
  final bool isVerified;
  final bool isSuperhost;
  final double? averageRating;
  final int? ratingCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserProfileEntity({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.photoUrl,
    this.bio,
    this.followerCount = 0,
    this.followingCount = 0,
    this.postCount = 0,
    this.isVerified = false,
    this.isSuperhost = false,
    this.averageRating,
    this.ratingCount,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        photoUrl,
        bio,
        followerCount,
        followingCount,
        postCount,
        isVerified,
        isSuperhost,
        averageRating,
        ratingCount,
        createdAt,
        updatedAt,
      ];

  /// Create a copy with modified fields
  UserProfileEntity copyWith({
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
    return UserProfileEntity(
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
