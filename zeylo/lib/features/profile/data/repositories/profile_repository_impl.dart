import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_datasource.dart';
import '../models/user_profile_model.dart';

/// Implementation of ProfileRepository
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDatasource _datasource;

  ProfileRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, UserProfileEntity>> getProfile(String userId) async {
    try {
      final profile = await _datasource.getProfile(userId);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> updateProfile(
    String userId,
    UserProfileEntity profile,
  ) async {
    try {
      final profileModel = UserProfileModel(
        id: profile.id,
        name: profile.name,
        email: profile.email,
        phone: profile.phone,
        photoUrl: profile.photoUrl,
        bio: profile.bio,
        followerCount: profile.followerCount,
        followingCount: profile.followingCount,
        postCount: profile.postCount,
        isVerified: profile.isVerified,
        isSuperhost: profile.isSuperhost,
        averageRating: profile.averageRating,
        ratingCount: profile.ratingCount,
        createdAt: profile.createdAt,
        updatedAt: DateTime.now(),
      );

      final updated = await _datasource.updateProfile(userId, profileModel);
      return Right(updated);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserProfileEntity>>> getFollowers(
    String userId,
  ) async {
    try {
      final followers = await _datasource.getFollowers(userId);
      return Right(followers);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserProfileEntity>>> getFollowing(
    String userId,
  ) async {
    try {
      final following = await _datasource.getFollowing(userId);
      return Right(following);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> followUser(
    String currentUserId,
    String targetUserId,
  ) async {
    try {
      await _datasource.followUser(currentUserId, targetUserId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unfollowUser(
    String currentUserId,
    String targetUserId,
  ) async {
    try {
      await _datasource.unfollowUser(currentUserId, targetUserId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isFollowing(
    String currentUserId,
    String targetUserId,
  ) async {
    try {
      final following = await _datasource.isFollowing(
        currentUserId,
        targetUserId,
      );
      return Right(following);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserProfileEntity>>> getSuggestedUsers(String currentUserId, {int limit = 10}) async {
    try {
      final suggestions = await _datasource.getSuggestedUsers(currentUserId, limit: limit);
      return Right(suggestions);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(String userId, Uint8List imageBytes) async {
    try {
      final url = await _datasource.uploadProfileImage(userId, imageBytes);
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncHostProfileToExperiences(String hostId, String name, String? photoUrl) async {
    try {
      await _datasource.syncHostProfileToExperiences(hostId, name, photoUrl);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
