import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/moment_entity.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/community_remote_datasource.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/moment_model.dart';

/// Implementation of CommunityRepository
class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityRemoteDataSource remoteDataSource;

  CommunityRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<Post>> watchCommunityPosts({int limit = 50}) {
    return remoteDataSource
        .watchCommunityPosts(limit: limit)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, List<Post>>> getCommunityPosts({int limit = 20}) async {
    try {
      final posts = await remoteDataSource.getCommunityPosts(limit: limit);
      return Right(posts.map((p) => p.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getUserPosts(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final posts =
          await remoteDataSource.getUserPosts(userId, limit: limit);
      return Right(posts.map((p) => p.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getPostsByTag(
    String tag, {
    int limit = 20,
  }) async {
    try {
      final posts = await remoteDataSource.getPostsByTag(tag, limit: limit);
      return Right(posts.map((p) => p.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> likePost(
    String postId,
    String userId,
    String userName,
  ) async {
    try {
      await remoteDataSource.likePost(postId, userId, userName);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unlikePost(String postId, String userId) async {
    try {
      await remoteDataSource.unlikePost(postId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isPostLiked(String postId, String userId) async {
    try {
      final isLiked = await remoteDataSource.isPostLiked(postId, userId);
      return Right(isLiked);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<Comment>> watchComments(String postId) {
    return remoteDataSource
        .watchComments(postId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, void>> addComment(String postId, Comment comment) async {
    try {
      final commentModel = _commentToModel(comment);
      await remoteDataSource.addComment(postId, commentModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createPost(Post post) async {
    try {
      final postModel = _postToModel(post);
      final postId = await remoteDataSource.createPost(postModel);
      return Right(postId);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    try {
      await remoteDataSource.deletePost(postId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<Moment>> watchMoments() {
    return remoteDataSource
        .watchMoments()
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, void>> addMoment(Moment moment) async {
    try {
      final model = MomentModel.fromEntity(moment);
      await remoteDataSource.addMoment(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // Helper methods to convert entities to models
  PostModel _postToModel(Post post) {
    return PostModel(
      id: post.id,
      userId: post.userId,
      userName: post.userName,
      userAvatar: post.userAvatar,
      images: post.images,
      caption: post.caption,
      likesCount: post.likesCount,
      commentsCount: post.commentsCount,
      createdAt: post.createdAt,
      tags: post.tags,
      experienceTag: post.experienceTag,
    );
  }

  CommentModel _commentToModel(Comment comment) {
    return CommentModel(
      id: comment.id,
      userId: comment.userId,
      userName: comment.userName,
      userAvatar: comment.userAvatar,
      text: comment.text,
      createdAt: comment.createdAt,
    );
  }
}
