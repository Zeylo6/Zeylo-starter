import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/datasources/community_remote_datasource.dart';
import '../../data/repositories/community_repository_impl.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/moment_entity.dart';
import '../../domain/repositories/community_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

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

// Stream Provider for real-time posts
final communityPostsProvider = StreamProvider<List<Post>>((ref) {
  final repository = ref.watch(communityRepositoryProvider);
  return repository.watchCommunityPosts(limit: 50);
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

// Stream Provider for real-time comments
final commentsProvider = StreamProvider.family<List<Comment>, String>((ref, postId) {
  final repository = ref.watch(communityRepositoryProvider);
  return repository.watchComments(postId);
});

// Provider to check if a post is liked by the current user
final isPostLikedProvider = FutureProvider.family<bool, String>((ref, postId) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return false;
  
  final repository = ref.watch(communityRepositoryProvider);
  final result = await repository.isPostLiked(postId, user.uid);
  
  return result.fold(
    (failure) => false,
    (isLiked) => isLiked,
  );
});

// Mutation providers
final likePostProvider = FutureProvider.family<void, String>(
  (ref, postId) async {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) throw Exception('User not authenticated');

    final repository = ref.watch(communityRepositoryProvider);
    final result = await repository.likePost(postId, user.uid, user.displayName);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        ref.invalidate(isPostLikedProvider(postId));
      },
    );
  },
);

final unlikePostProvider = FutureProvider.family<void, String>(
  (ref, postId) async {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) throw Exception('User not authenticated');

    final repository = ref.watch(communityRepositoryProvider);
    final result = await repository.unlikePost(postId, user.uid);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        ref.invalidate(isPostLikedProvider(postId));
      },
    );
  },
);

final addCommentProvider = FutureProvider.family<void, ({String postId, String text})>(
  (ref, params) async {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) throw Exception('User not authenticated');

    final repository = ref.watch(communityRepositoryProvider);
    final comment = Comment(
      id: '', // Firestore will generate ID
      userId: user.uid,
      userName: user.displayName,
      userAvatar: user.photoUrl ?? '',
      text: params.text,
      createdAt: DateTime.now(),
    );

    final result = await repository.addComment(params.postId, comment);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (_) => null,
    );
  },
);

final deletePostProvider = FutureProvider.family<void, String>(
  (ref, postId) async {
    final repository = ref.watch(communityRepositoryProvider);
    final result = await repository.deletePost(postId);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        ref.invalidate(communityPostsProvider);
      },
    );
  },
);

final momentsProvider = StreamProvider<List<Moment>>((ref) {
  final repository = ref.watch(communityRepositoryProvider);
  return repository.watchMoments();
});

final addMomentProvider = FutureProvider.family<void, Moment>((ref, moment) async {
  final repository = ref.watch(communityRepositoryProvider);
  final result = await repository.addMoment(moment);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (_) => null,
  );
});
