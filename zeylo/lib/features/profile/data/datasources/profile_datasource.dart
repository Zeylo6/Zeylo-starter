import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_model.dart';

/// Abstract datasource for profile operations
abstract class ProfileDatasource {
  /// Get user profile by ID
  Future<UserProfileModel> getProfile(String userId);

  /// Update user profile
  Future<UserProfileModel> updateProfile(
    String userId,
    UserProfileModel profile,
  );

  /// Get followers for a user
  Future<List<UserProfileModel>> getFollowers(String userId);

  /// Get following list for a user
  Future<List<UserProfileModel>> getFollowing(String userId);

  /// Follow a user
  Future<void> followUser(String currentUserId, String targetUserId);

  /// Unfollow a user
  Future<void> unfollowUser(String currentUserId, String targetUserId);

  /// Check if current user follows target user
  Future<bool> isFollowing(String currentUserId, String targetUserId);
}

/// Firestore implementation of profile datasource
class ProfileFirestoreDatasource implements ProfileDatasource {
  final FirebaseFirestore _firestore;

  ProfileFirestoreDatasource(this._firestore);

  static const String _usersCollection = 'users';
  static const String _followersCollection = 'followers';
  static const String _followingCollection = 'following';

  @override
  Future<UserProfileModel> getProfile(String userId) async {
    final doc = await _firestore.collection(_usersCollection).doc(userId).get();

    if (!doc.exists) {
      throw Exception('User profile not found');
    }

    return UserProfileModel.fromFirestore(
      doc as DocumentSnapshot<Map<String, dynamic>>,
    );
  }

  @override
  Future<UserProfileModel> updateProfile(
    String userId,
    UserProfileModel profile,
  ) async {
    await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .update(profile.toFirestore());

    return await getProfile(userId);
  }

  @override
  Future<List<UserProfileModel>> getFollowers(String userId) async {
    try {
      final followersSnapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_followersCollection)
          .get();

      final profiles = <UserProfileModel>[];

      for (final followerDoc in followersSnapshot.docs) {
        final followerId = followerDoc.id;
        final userDoc = await _firestore
            .collection(_usersCollection)
            .doc(followerId)
            .get();

        if (userDoc.exists) {
          profiles.add(
            UserProfileModel.fromFirestore(
              userDoc as DocumentSnapshot<Map<String, dynamic>>,
            ),
          );
        }
      }

      return profiles;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<UserProfileModel>> getFollowing(String userId) async {
    try {
      final followingSnapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_followingCollection)
          .get();

      final profiles = <UserProfileModel>[];

      for (final followingDoc in followingSnapshot.docs) {
        final targetId = followingDoc.id;
        final userDoc = await _firestore
            .collection(_usersCollection)
            .doc(targetId)
            .get();

        if (userDoc.exists) {
          profiles.add(
            UserProfileModel.fromFirestore(
              userDoc as DocumentSnapshot<Map<String, dynamic>>,
            ),
          );
        }
      }

      return profiles;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> followUser(String currentUserId, String targetUserId) async {
    // Add to current user's following collection
    await _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .collection(_followingCollection)
        .doc(targetUserId)
        .set({'followedAt': Timestamp.now()});

    // Add to target user's followers collection
    await _firestore
        .collection(_usersCollection)
        .doc(targetUserId)
        .collection(_followersCollection)
        .doc(currentUserId)
        .set({'followedAt': Timestamp.now()});

    // Update follower/following counts
    await _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .update({
          'followingCount': FieldValue.increment(1),
        });

    await _firestore
        .collection(_usersCollection)
        .doc(targetUserId)
        .update({
          'followerCount': FieldValue.increment(1),
        });
  }

  @override
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    // Remove from current user's following collection
    await _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .collection(_followingCollection)
        .doc(targetUserId)
        .delete();

    // Remove from target user's followers collection
    await _firestore
        .collection(_usersCollection)
        .doc(targetUserId)
        .collection(_followersCollection)
        .doc(currentUserId)
        .delete();

    // Update follower/following counts
    await _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .update({
          'followingCount': FieldValue.increment(-1),
        });

    await _firestore
        .collection(_usersCollection)
        .doc(targetUserId)
        .update({
          'followerCount': FieldValue.increment(-1),
        });
  }

  @override
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(currentUserId)
          .collection(_followingCollection)
          .doc(targetUserId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}
