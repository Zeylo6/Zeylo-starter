import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post_entity.dart';
import '../entities/comment_entity.dart';
import '../entities/moment_entity.dart';

/// Abstract repository for community feature
abstract class CommunityRepository {
  /// Get community posts (feed) — one-time fetch
  Future<Either<Failure, List<Post>>> getCommunityPosts({int limit = 20});

  /// Watch community posts (feed) — real-time stream
  Stream<List<Post>> watchCommunityPosts({int limit = 50});

  /// Get user's posts
  Future<Either<Failure, List<Post>>> getUserPosts(
    String userId, {
    int limit = 20,
  });

  /// Get posts by tag
  Future<Either<Failure, List<Post>>> getPostsByTag(
    String tag, {
    int limit = 20,
  });

  /// Like a post
  Future<Either<Failure, void>> likePost(String postId, String userId, String userName);

  /// Unlike a post
  Future<Either<Failure, void>> unlikePost(String postId, String userId);

  /// Check if a post is liked by a user
  Future<Either<Failure, bool>> isPostLiked(String postId, String userId);

  /// Watch comments for a post
  Stream<List<Comment>> watchComments(String postId);

  /// Add a comment to a post
  Future<Either<Failure, void>> addComment(String postId, Comment comment);

  /// Create a new post
  Future<Either<Failure, String>> createPost(Post post);

  /// Delete a post
  Future<Either<Failure, void>> deletePost(String postId);

  /// Watch moments (stories) — real-time stream
  Stream<List<Moment>> watchMoments();

  /// Add a moment (story)
  Future<Either<Failure, void>> addMoment(Moment moment);
}
