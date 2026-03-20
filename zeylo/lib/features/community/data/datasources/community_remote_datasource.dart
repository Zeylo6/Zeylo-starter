import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

/// Abstract remote data source for community feature
abstract class CommunityRemoteDataSource {
  /// Get community posts (feed) — one-time fetch
  Future<List<PostModel>> getCommunityPosts({int limit = 20});

  /// Watch community posts (feed) — real-time stream
  Stream<List<PostModel>> watchCommunityPosts({int limit = 50});

  /// Get user's posts
  Future<List<PostModel>> getUserPosts(String userId, {int limit = 20});

  /// Get posts by tag
  Future<List<PostModel>> getPostsByTag(String tag, {int limit = 20});

  /// Like a post
  Future<void> likePost(String postId);

  /// Unlike a post
  Future<void> unlikePost(String postId);

  /// Create a new post
  Future<String> createPost(PostModel post);

  /// Delete a post
  Future<void> deletePost(String postId);
}

/// Implementation of CommunityRemoteDataSource using Firestore
class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  final FirebaseFirestore _firestore;

  CommunityRemoteDataSourceImpl(this._firestore);

  @override
  Stream<List<PostModel>> watchCommunityPosts({int limit = 50}) {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
  }

  @override
  Future<List<PostModel>> getCommunityPosts({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PostModel>> getUserPosts(String userId, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PostModel>> getPostsByTag(String tag, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .where('tags', arrayContains: tag)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> likePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'likesCount': FieldValue.increment(1),
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unlikePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'likesCount': FieldValue.increment(-1),
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> createPost(PostModel post) async {
    try {
      final doc = await _firestore.collection('posts').add(post.toFirestore());
      return doc.id;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
