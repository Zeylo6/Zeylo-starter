import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import '../models/user_profile_model.dart';

/// Abstract datasource for profile operations
abstract class ProfileDatasource {
  /// Get user profile by ID
  Future<UserProfileModel> getProfile(String userId);

  /// Watch user profile by ID
  Stream<UserProfileModel> watchProfile(String userId);

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

  /// Get suggested users to follow
  Future<List<UserProfileModel>> getSuggestedUsers(String currentUserId, {int limit = 10});

  /// Upload profile image to storage
  Future<String> uploadProfileImage(String userId, Uint8List imageBytes);

  /// Synchronize host profile changes to their experiences
  Future<void> syncHostProfileToExperiences(String hostId, String name, String? photoUrl);
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
      doc,
    );
  }

  @override
  Stream<UserProfileModel> watchProfile(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        throw Exception('User profile not found');
      }
      return UserProfileModel.fromFirestore(doc);
    });
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
              userDoc,
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
              userDoc,
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

  @override
  Future<List<UserProfileModel>> getSuggestedUsers(String currentUserId, {int limit = 10}) async {
    try {
      // Get users ordered by follower count
      final snapshot = await _firestore
          .collection(_usersCollection)
          .orderBy('followerCount', descending: true)
          .limit(limit + 5) // Fetch a few extra in case we need to filter out the current user or already followed users
          .get();

      // Get the list of users the current user is already following
      final followingSnapshot = await _firestore
          .collection(_usersCollection)
          .doc(currentUserId)
          .collection(_followingCollection)
          .get();
          
      final followingIds = followingSnapshot.docs.map((doc) => doc.id).toSet();
      followingIds.add(currentUserId); // Add current user to filter out

      final suggestions = <UserProfileModel>[];

      for (final doc in snapshot.docs) {
        if (!followingIds.contains(doc.id)) {
          suggestions.add(UserProfileModel.fromFirestore(doc));
          if (suggestions.length >= limit) break;
        }
      }

      return suggestions;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<String> uploadProfileImage(String userId, Uint8List imageBytes) async {
    const cloudName = 'deukwmcoi';
    const uploadPreset = 'Zeylo_images';

    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(http.MultipartFile.fromBytes(
          'file', 
          imageBytes, 
          filename: 'profile_$userId.jpg',
        ));

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);

      if (response.statusCode == 200) {
        return jsonMap['secure_url'];
      } else {
        debugPrint('Cloudinary Error: ${jsonMap['error']['message']}');
        throw Exception('Cloudinary upload failed: ${jsonMap['error']['message']}');
      }
    } catch (e) {
      debugPrint("Upload error: $e");
      rethrow;
    }
  }

  @override
  Future<void> syncHostProfileToExperiences(
    String hostId,
    String name,
    String? photoUrl,
  ) async {
    final experiencesSnapshot = await _firestore
        .collection('experiences')
        .where('hostId', isEqualTo: hostId)
        .get();

    if (experiencesSnapshot.docs.isEmpty) return;

    final batch = _firestore.batch();

    for (final doc in experiencesSnapshot.docs) {
      batch.update(doc.reference, {
        'hostName': name,
        if (photoUrl != null) 'hostPhotoUrl': photoUrl,
      });
    }

    await batch.commit();
  }
}
