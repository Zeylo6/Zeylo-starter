import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/profile_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../profile/domain/entities/user_profile_entity.dart';

// Datasource provider
final profileDatasourceProvider = Provider((ref) {
  return ProfileFirestoreDatasource(FirebaseFirestore.instance);
});

// Repository provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final datasource = ref.watch(profileDatasourceProvider);
  return ProfileRepositoryImpl(datasource);
});

// State notifier for profile
class ProfileNotifier extends StateNotifier<AsyncValue<UserProfileEntity>> {
  final ProfileRepository repository;
  final String userId;

  ProfileNotifier({required this.repository, required this.userId})
      : super(const AsyncValue.loading());

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    final result = await repository.getProfile(userId);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (profile) => state = AsyncValue.data(profile),
    );
  }

  Future<void> updateProfile(UserProfileEntity profile) async {
    state = const AsyncValue.loading();
    final result = await repository.updateProfile(userId, profile);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (profile) => state = AsyncValue.data(profile),
    );
  }
}

// Profile provider family
final profileProvider =
    StateNotifierProvider.family<ProfileNotifier, AsyncValue<UserProfileEntity>, String>(
  (ref, userId) {
    final repository = ref.watch(profileRepositoryProvider);
    final notifier = ProfileNotifier(repository: repository, userId: userId);
    notifier.loadProfile();
    return notifier;
  },
);

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
        },
      );
    }
  },
);
