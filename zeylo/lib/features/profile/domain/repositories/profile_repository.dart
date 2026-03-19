import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile_entity.dart';

/// Abstract repository for profile-related operations
abstract class ProfileRepository {
  /// Get user profile by ID
  Future<Either<Failure, UserProfileEntity>> getProfile(String userId);

  /// Watch user profile by ID
  Stream<Either<Failure, UserProfileEntity>> watchProfile(String userId);

  /// Update user profile
  Future<Either<Failure, UserProfileEntity>> updateProfile(
    String userId,
    UserProfileEntity profile,
  );

  /// Get followers for a user
  Future<Either<Failure, List<UserProfileEntity>>> getFollowers(
    String userId,
  );

  /// Get following list for a user
  Future<Either<Failure, List<UserProfileEntity>>> getFollowing(
    String userId,
  );

  /// Follow a user
  Future<Either<Failure, void>> followUser(
    String currentUserId,
    String targetUserId,
  );

  /// Unfollow a user
  Future<Either<Failure, void>> unfollowUser(
    String currentUserId,
    String targetUserId,
  );

  /// Check if current user follows target user
  Future<Either<Failure, bool>> isFollowing(
    String currentUserId,
    String targetUserId,
  );

  /// Get suggested users to follow
  Future<Either<Failure, List<UserProfileEntity>>> getSuggestedUsers(
    String currentUserId, {
    int limit = 10,
  });

  /// Upload profile image
  Future<Either<Failure, String>> uploadProfileImage(String userId, Uint8List imageBytes);

  /// Synchronize host profile to experiences
  Future<Either<Failure, void>> syncHostProfileToExperiences(String hostId, String name, String? photoUrl);
}
