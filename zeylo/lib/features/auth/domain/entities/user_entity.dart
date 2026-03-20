/// Role of the user in the Zeylo application
enum UserRole {
  seeker,
  host,
  business,
  admin,
}

/// Verification status for host applications
enum HostVerificationStatus {
  unverified,
  pending,
  verified,
  rejected,
}

/// User entity representing a user in the Zeylo application
class UserEntity {
  /// Unique identifier for the user
  final String uid;

  /// User's email address
  final String email;

  /// User's full display name
  final String displayName;

  /// URL to user's profile photo
  final String? photoUrl;

  /// User's phone number
  final String? phoneNumber;

  /// User's bio/description
  final String? bio;

  /// User's location (city, country)
  final Map<String, String>? location;

  /// The user's role, determining permissions and app behavior
  final UserRole role;

  /// The host's verification status
  final HostVerificationStatus hostVerificationStatus;

  /// Whether the user's email is verified
  final bool isVerified;

  /// Account creation timestamp
  final DateTime createdAt;

  /// Number of followers
  final int followersCount;

  /// Number of users this user follows
  final int followingCount;

  /// Number of posts created by the user
  final int postsCount;

  /// Firebase Cloud Messaging token for push notifications
  final String? fcmToken;

  /// List of favorite experience IDs
  final List<String> favorites;

  /// User setting/preferences
  final Map<String, dynamic> settings;

  /// User statistics (average rating, total reviews)
  final Map<String, dynamic> stats;

  /// Whether the user is banned
  final bool isBanned;

  /// The reason for the ban
  final String? banReason;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.bio,
    this.location,
    this.role = UserRole.seeker,
    this.hostVerificationStatus = HostVerificationStatus.unverified,
    this.isVerified = false,
    required this.createdAt,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.fcmToken,
    this.favorites = const [],
    this.settings = const {},
    this.stats = const {},
    this.isBanned = false,
    this.banReason,
  });

  /// Create a copy of this user entity with some fields replaced
  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    String? bio,
    Map<String, String>? location,
    UserRole? role,
    HostVerificationStatus? hostVerificationStatus,
    bool? isVerified,
    DateTime? createdAt,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    String? fcmToken,
    List<String>? favorites,
    Map<String, dynamic>? settings,
    Map<String, dynamic>? stats,
    bool? isBanned,
    String? banReason,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      role: role ?? this.role,
      hostVerificationStatus:
          hostVerificationStatus ?? this.hostVerificationStatus,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      fcmToken: fcmToken ?? this.fcmToken,
      favorites: favorites ?? this.favorites,
      settings: settings ?? this.settings,
      stats: stats ?? this.stats,
      isBanned: isBanned ?? this.isBanned,
      banReason: banReason ?? this.banReason,
    );
  }

  @override
  String toString() => 'UserEntity('
      'uid: $uid, '
      'email: $email, '
      'displayName: $displayName, '
      'isVerified: $isVerified, '
      'role: ${role.name}'
      ')';
}
