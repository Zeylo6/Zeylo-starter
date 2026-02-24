import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Favorite experience model
class FavoriteExperience {
  final String id;
  final String title;
  final String hostName;
  final String imageUrl;
  final String? hostAvatarUrl;
  final String location;
  final String price;
  final String description;
  final double? rating;
  final int? ratingCount;
  final DateTime addedAt;

  const FavoriteExperience({
    required this.id,
    required this.title,
    required this.hostName,
    required this.imageUrl,
    required this.location,
    required this.price,
    required this.description,
    this.hostAvatarUrl,
    this.rating,
    this.ratingCount,
    required this.addedAt,
  });

  FavoriteExperience copyWith({
    String? id,
    String? title,
    String? hostName,
    String? imageUrl,
    String? hostAvatarUrl,
    String? location,
    String? price,
    String? description,
    double? rating,
    int? ratingCount,
    DateTime? addedAt,
  }) {
    return FavoriteExperience(
      id: id ?? this.id,
      title: title ?? this.title,
      hostName: hostName ?? this.hostName,
      imageUrl: imageUrl ?? this.imageUrl,
      hostAvatarUrl: hostAvatarUrl ?? this.hostAvatarUrl,
      location: location ?? this.location,
      price: price ?? this.price,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

/// Favorites state
class FavoritesState {
  final List<FavoriteExperience> favorites;
  final bool isLoading;
  final String? error;
  final String? sortBy; // newest, oldest, title, price

  const FavoritesState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
    this.sortBy = 'newest',
  });

  FavoritesState copyWith({
    List<FavoriteExperience>? favorites,
    bool? isLoading,
    String? error,
    String? sortBy,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

/// Favorites notifier
class FavoritesNotifier extends StateNotifier<FavoritesState> {
  FavoritesNotifier() : super(const FavoritesState());

  /// Load favorites (mock implementation)
  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final mockFavorites = [
        FavoriteExperience(
          id: '1',
          title: 'Street Food Tour',
          hostName: 'John Doe',
          imageUrl: 'https://example.com/image1.jpg',
          location: 'Colombo, Sri Lanka',
          price: 'LKR 2,500',
          description: 'An amazing street food tour',
          rating: 4.8,
          ratingCount: 234,
          addedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        FavoriteExperience(
          id: '2',
          title: 'Sunset Kayaking',
          hostName: 'Jane Smith',
          imageUrl: 'https://example.com/image2.jpg',
          location: 'Mount Lavinia Beach',
          price: 'LKR 3,500',
          description: 'Peaceful kayaking experience at sunset',
          rating: 4.9,
          ratingCount: 189,
          addedAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];

      state = state.copyWith(
        favorites: mockFavorites,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Add favorite
  Future<void> addFavorite(FavoriteExperience experience) async {
    final updated = [...state.favorites, experience];
    state = state.copyWith(favorites: updated);
  }

  /// Remove favorite
  Future<void> removeFavorite(String experienceId) async {
    final updated = state.favorites
        .where((fav) => fav.id != experienceId)
        .toList();
    state = state.copyWith(favorites: updated);
  }

  /// Toggle favorite
  Future<void> toggleFavorite(FavoriteExperience experience) async {
    final isFavorited = state.favorites.any((fav) => fav.id == experience.id);
    if (isFavorited) {
      await removeFavorite(experience.id);
    } else {
      await addFavorite(experience);
    }
  }

  /// Sort favorites
  void sortFavorites(String sortBy) {
    List<FavoriteExperience> sorted = List.from(state.favorites);

    switch (sortBy) {
      case 'newest':
        sorted.sort((a, b) => b.addedAt.compareTo(a.addedAt));
        break;
      case 'oldest':
        sorted.sort((a, b) => a.addedAt.compareTo(b.addedAt));
        break;
      case 'title':
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'price':
        sorted.sort((a, b) {
          // Simple numeric comparison (assuming price is numeric)
          final priceA = double.tryParse(a.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
          final priceB = double.tryParse(b.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
          return priceA.compareTo(priceB);
        });
        break;
    }

    state = state.copyWith(favorites: sorted, sortBy: sortBy);
  }

  /// Check if experience is favorited
  bool isFavorited(String experienceId) {
    return state.favorites.any((fav) => fav.id == experienceId);
  }
}

/// Favorites provider
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>(
  (ref) => FavoritesNotifier(),
);

/// Get single favorite
final favoriteProvider = Provider.family<FavoriteExperience?, String>(
  (ref, experienceId) {
    final state = ref.watch(favoritesProvider);
    return state.favorites.cast<FavoriteExperience?>().firstWhere(
          (fav) => fav?.id == experienceId,
          orElse: () => null,
        );
  },
);
