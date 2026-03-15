import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/community_remote_datasource.dart';
import '../models/post_model.dart';

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
  Future<Either<Failure, void>> likePost(String postId) async {
    try {
      await remoteDataSource.likePost(postId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unlikePost(String postId) async {
    try {
      await remoteDataSource.unlikePost(postId);
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
      // Convert entity to model
      final postModel = _postToModel(post);
      final postId = await remoteDataSource.createPost(postModel);
      return Right(postId);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // Helper method to convert Post entity to PostModel
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
}
