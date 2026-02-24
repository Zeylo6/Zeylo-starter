import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/datasources/community_remote_datasource.dart';
import '../../data/repositories/community_repository_impl.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/community_repository.dart';

// Dependencies
final firebaseFirestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final communityRemoteDataSourceProvider = Provider<CommunityRemoteDataSource>(
  (ref) {
    final firestore = ref.watch(firebaseFirestoreProvider);
    return CommunityRemoteDataSourceImpl(firestore);
  },
);

final communityRepositoryProvider = Provider<CommunityRepository>(
  (ref) {
    final remoteDataSource = ref.watch(communityRemoteDataSourceProvider);
    return CommunityRepositoryImpl(remoteDataSource: remoteDataSource);
  },
);

// State Providers
final selectedTagProvider = StateProvider<String?>((ref) => null);

// Future Providers
final communityPostsProvider = FutureProvider<List<Post>>((ref) async {
  final repository = ref.watch(communityRepositoryProvider);
  final result = await repository.getCommunityPosts(limit: 50);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (posts) => posts,
  );
});

final userPostsProvider = FutureProvider.family<List<Post>, String>(
  (ref, userId) async {
    final repository = ref.watch(communityRepositoryProvider);
    final result = await repository.getUserPosts(userId, limit: 50);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (posts) => posts,
    );
  },
);

final taggedPostsProvider = FutureProvider.family<List<Post>, String>(
  (ref, tag) async {
    final repository = ref.watch(communityRepositoryProvider);
    final result = await repository.getPostsByTag(tag, limit: 50);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (posts) => posts,
    );
  },
);

// Mutation providers
final likePostProvider = FutureProvider.family<void, String>(
  (ref, postId) async {
    final repository = ref.watch(communityRepositoryProvider);
    final result = await repository.likePost(postId);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        ref.refresh(communityPostsProvider);
      },
    );
  },
);

final unlikePostProvider = FutureProvider.family<void, String>(
  (ref, postId) async {
    final repository = ref.watch(communityRepositoryProvider);
    final result = await repository.unlikePost(postId);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        ref.refresh(communityPostsProvider);
      },
    );
  },
);
