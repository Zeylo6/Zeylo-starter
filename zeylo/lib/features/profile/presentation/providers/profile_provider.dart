import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/profile_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../profile/domain/entities/user_profile_entity.dart';

final profileDatasourceProvider = Provider<ProfileDatasource>((ref) {
  return ProfileFirestoreDatasource(
    FirebaseFirestore.instance,
  );
});

// Repository provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final datasource = ref.watch(profileDatasourceProvider);
  return ProfileRepositoryImpl(datasource);
});

// Profile provider family (Stream-based for real-time updates)
final profileProvider = StreamProvider.family<UserProfileEntity, String>((ref, userId) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.watchProfile(userId).map((result) => result.fold(
        (failure) => throw failure.message,
        (profile) => profile,
      ));
});

// Followers provider family
final followersProvider = FutureProvider.family<List<UserProfileEntity>, String>(
  (ref, userId) async {
    final repository = ref.watch(profileRepositoryProvider);
    final result = await repository.getFollowers(userId);
    return result.fold(
      (failure) => throw failure.message,
      (followers) => followers,
    );
  },
);

// Following provider family
final followingProvider = FutureProvider.family<List<UserProfileEntity>, String>(
  (ref, userId) async {
    final repository = ref.watch(profileRepositoryProvider);
    final result = await repository.getFollowing(userId);
    return result.fold(
      (failure) => throw failure.message,
      (following) => following,
    );
  },
);

/// Provider to search for user profiles
final searchProfilesProvider = FutureProvider.family<List<UserProfileEntity>, String>(
  (ref, query) async {
    if (query.isEmpty) return [];
    final repository = ref.watch(profileRepositoryProvider);
    final result = await repository.searchProfiles(query);
    return result.fold(
      (failure) => throw failure.message,
      (profiles) => profiles,
    );
  },
);

// Is following provider family
final isFollowingProvider =
    FutureProvider.family<bool, (String currentUserId, String targetUserId)>(
  (ref, params) async {
    final repository = ref.watch(profileRepositoryProvider);
    final result = await repository.isFollowing(params.$1, params.$2);
    return result.fold(
      (failure) => throw failure.message,
      (isFollowing) => isFollowing,
    );
  },
);

// Suggested users provider family
final suggestedUsersProvider = FutureProvider.family<List<UserProfileEntity>, String>(
  (ref, userId) async {
    final repository = ref.watch(profileRepositoryProvider);
    final result = await repository.getSuggestedUsers(userId);
    return result.fold(
      (failure) => throw failure.message,
      (suggestions) => suggestions,
    );
  },
);

// Follow/Unfollow action
final followActionProvider = FutureProvider.family<void, (String currentUserId, String targetUserId, bool follow)>(
  (ref, params) async {
    final repository = ref.watch(profileRepositoryProvider);
    final (currentUserId, targetUserId, follow) = params;

    if (follow) {
      final result = await repository.followUser(currentUserId, targetUserId);
      result.fold(
        (failure) => throw failure.message,
        (_) {
          // Invalidate related providers
          ref.invalidate(followersProvider);
          ref.invalidate(followingProvider);
          ref.invalidate(isFollowingProvider);
          ref.invalidate(suggestedUsersProvider);
        },
      );
    } else {
      final result = await repository.unfollowUser(currentUserId, targetUserId);
      result.fold(
        (failure) => throw failure.message,
        (_) {
          // Invalidate related providers
          ref.invalidate(followersProvider);
          ref.invalidate(followingProvider);
          ref.invalidate(isFollowingProvider);
          ref.invalidate(suggestedUsersProvider);
        },
      );
    }
  },
);
