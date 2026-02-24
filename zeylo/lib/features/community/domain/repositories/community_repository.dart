import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post_entity.dart';

/// Abstract repository for community feature
abstract class CommunityRepository {
  /// Get community posts (feed)
  Future<Either<Failure, List<Post>>> getCommunityPosts({int limit = 20});

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
  Future<Either<Failure, void>> likePost(String postId);

  /// Unlike a post
  Future<Either<Failure, void>> unlikePost(String postId);

  /// Create a new post
  Future<Either<Failure, String>> createPost(Post post);
}
