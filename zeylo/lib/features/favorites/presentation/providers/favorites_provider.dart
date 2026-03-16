import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/domain/entities/experience_entity.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../home/domain/repositories/home_repository.dart';

/// Favorites state
class FavoritesState {
  final List<Experience> favorites;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
  });

  FavoritesState copyWith({
    List<Experience>? favorites,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Favorites notifier
class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final HomeRepository _homeRepository;
  final Ref _ref;

  FavoritesNotifier(this._homeRepository, this._ref) : super(const FavoritesState());

  /// Load favorites using IDs from current user
  Future<void> loadFavorites(List<String> favoriteIds) async {
    if (favoriteIds.isEmpty) {
      state = state.copyWith(favorites: [], isLoading: false, error: null);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final result = await _homeRepository.getExperiencesByIds(favoriteIds);
    
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (experiences) => state = state.copyWith(favorites: experiences, isLoading: false),
    );
  }

  /// Toggle favorite status in Firestore
  Future<void> toggleFavorite(String experienceId) async {
    final user = _ref.read(currentUserProvider).value;
    if (user == null) return;

    final updatedFavorites = List<String>.from(user.favorites);
    if (updatedFavorites.contains(experienceId)) {
      updatedFavorites.remove(experienceId);
    } else {
      updatedFavorites.add(experienceId);
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'favorites': updatedFavorites});
    } catch (e) {
      state = state.copyWith(error: 'Failed to update favorites: $e');
    }
  }

  /// Check if an experience is favorited
  bool isFavorited(String experienceId) {
    final user = _ref.read(currentUserProvider).value;
    return user?.favorites.contains(experienceId) ?? false;
  }
}

/// Favorites provider
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>(
  (ref) {
    final repository = ref.watch(homeRepositoryProvider);
    final notifier = FavoritesNotifier(repository, ref);
    
    // Auto-load favorites when current user's favorites list changes
    ref.listen(currentUserProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        final newIds = next.value!.favorites;
        final oldIds = previous?.value?.favorites ?? [];
        
        // Only reload if the IDs list has actually changed (basic check)
        if (newIds.length != oldIds.length || !newIds.every((id) => oldIds.contains(id))) {
          notifier.loadFavorites(newIds);
        }
      }
    }, fireImmediately: true);

    return notifier;
  },
);

/// Provider to check if a specific experience is favorited
final isFavoritedProvider = Provider.family<bool, String>((ref, experienceId) {
  final user = ref.watch(currentUserProvider).value;
  return user?.favorites.contains(experienceId) ?? false;
});
