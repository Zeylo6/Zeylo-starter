import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/moment_model.dart';
import './community_api_service.dart';

abstract class CommunityRemoteDataSource {
  Stream<List<PostModel>> watchCommunityPosts({int limit = 50});
  Future<List<PostModel>> getCommunityPosts({int limit = 20});
  Future<List<PostModel>> getUserPosts(String userId, {int limit = 20});
  Future<List<PostModel>> getPostsByTag(String tag, {int limit = 20});
  Future<void> likePost(String postId, String userId, String userName);
  Future<void> unlikePost(String postId, String userId);
  Future<bool> isPostLiked(String postId, String userId);
  Stream<List<CommentModel>> watchComments(String postId);
  Future<void> addComment(String postId, CommentModel comment);
  Future<String> createPost(PostModel post);
  Future<void> deletePost(String postId);
  Stream<List<MomentModel>> watchMoments();
  Future<void> addMoment(MomentModel moment);
}

class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  final FirebaseFirestore firestore;
  final CommunityApiService apiService = CommunityApiService();

  CommunityRemoteDataSourceImpl(this.firestore);

  @override
  Stream<List<PostModel>> watchCommunityPosts({int limit = 50}) {
    return firestore
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
      final snapshot = await firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<PostModel>> getUserPosts(String userId, {int limit = 20}) async {
    try {
      final snapshot = await firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<PostModel>> getPostsByTag(String tag, {int limit = 20}) async {
    try {
      final snapshot = await firestore
          .collection('posts')
          .where('tags', arrayContains: tag)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> likePost(String postId, String userId, String userName) async {
    try {
      final postRef = firestore.collection('posts').doc(postId);
      final likeRef = postRef.collection('likes').doc(userId);

      // Check if already liked to avoid duplicate notifications and count errors
      final likeDoc = await likeRef.get();
      if (likeDoc.exists) return;

      final batch = firestore.batch();

      batch.set(likeRef, {
        'userId': userId,
        'userName': userName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      batch.update(postRef, {
        'likesCount': FieldValue.increment(1),
      });

      await batch.commit();

      // Trigger notification
      final postDoc = await postRef.get();
      if (postDoc.exists) {
        final authorId = postDoc.data()?['userId'];
        if (authorId != null && authorId != userId) {
          apiService.notifyLike(
            authorId: authorId,
            likerName: userName,
            postId: postId,
          );
        }
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    try {
      final postRef = firestore.collection('posts').doc(postId);
      final likeRef = postRef.collection('likes').doc(userId);

      final likeDoc = await likeRef.get();
      if (!likeDoc.exists) return;

      final batch = firestore.batch();
      batch.delete(likeRef);
      batch.update(postRef, {
        'likesCount': FieldValue.increment(-1),
      });

      await batch.commit();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> isPostLiked(String postId, String userId) async {
    try {
      final likeDoc = await firestore
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(userId)
          .get();
      return likeDoc.exists;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<List<CommentModel>> watchComments(String postId) {
    return firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> addComment(String postId, CommentModel comment) async {
    try {
      final postRef = firestore.collection('posts').doc(postId);
      final commentRef = postRef.collection('comments').doc();

      final batch = firestore.batch();
      batch.set(commentRef, comment.toFirestore());
      batch.update(postRef, {
        'commentsCount': FieldValue.increment(1),
      });

      await batch.commit();

      // Trigger notification
      final postDoc = await postRef.get();
      if (postDoc.exists) {
        final authorId = postDoc.data()?['userId'];
        if (authorId != null && authorId != comment.userId) {
          apiService.notifyComment(
            authorId: authorId,
            commenterName: comment.userName,
            postId: postId,
            commentText: comment.text,
          );
        }
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> createPost(PostModel post) async {
    try {
      final docRef = await firestore.collection('posts').add(post.toFirestore());
      return docRef.id;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Stream<List<MomentModel>> watchMoments() {
    final now = DateTime.now();
    return firestore
        .collection('moments')
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('expiresAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MomentModel.fromFirestore(doc)).toList());
  }

  @override
  Future<void> addMoment(MomentModel moment) async {
    try {
      await firestore.collection('moments').add(moment.toFirestore());
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
