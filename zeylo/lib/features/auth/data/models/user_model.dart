import '../../domain/entities/user_entity.dart';

/// UserModel represents a user in Firestore and JSON format
///
/// Extends UserEntity to add serialization/deserialization capabilities
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.photoUrl,
    super.phoneNumber,
    super.bio,
    super.location,
    super.isHost,
    super.isVerified,
    required super.createdAt,
    super.followersCount,
    super.followingCount,
    super.postsCount,
    super.fcmToken,
    super.favorites,
    super.settings,
  });

  /// Create UserModel from JSON (for API responses)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] != null
          ? Map<String, String>.from(json['location'] as Map)
          : null,
      isHost: json['isHost'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      followersCount: json['followersCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
      postsCount: json['postsCount'] as int? ?? 0,
      fcmToken: json['fcmToken'] as String?,
      favorites: json['favorites'] != null
          ? List<String>.from(json['favorites'] as List)
          : [],
      settings: json['settings'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      bio: data['bio'] as String?,
      location: data['location'] != null
          ? Map<String, String>.from(data['location'] as Map)
          : null,
      isHost: data['isHost'] as bool? ?? false,
      isVerified: data['isVerified'] as bool? ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate() as DateTime
          : DateTime.now(),
      followersCount: data['followersCount'] as int? ?? 0,
      followingCount: data['followingCount'] as int? ?? 0,
      postsCount: data['postsCount'] as int? ?? 0,
      fcmToken: data['fcmToken'] as String?,
      favorites: data['favorites'] != null
          ? List<String>.from(data['favorites'] as List)
          : [],
      settings: data['settings'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'location': location,
      'isHost': isHost,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'fcmToken': fcmToken,
      'favorites': favorites,
      'settings': settings,
    };
  }

  /// Convert to Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'location': location,
      'isHost': isHost,
      'isVerified': isVerified,
      'createdAt': createdAt,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'fcmToken': fcmToken,
      'favorites': favorites,
      'settings': settings,
    };
  }

  /// Create a copy of this user model with some fields replaced
  @override
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    String? bio,
    Map<String, String>? location,
    bool? isHost,
    bool? isVerified,
    DateTime? createdAt,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    String? fcmToken,
    List<String>? favorites,
    Map<String, dynamic>? settings,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      isHost: isHost ?? this.isHost,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      fcmToken: fcmToken ?? this.fcmToken,
      favorites: favorites ?? this.favorites,
      settings: settings ?? this.settings,
    );
  }
}
