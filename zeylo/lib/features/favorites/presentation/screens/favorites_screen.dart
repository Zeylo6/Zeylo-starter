import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/experience_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../providers/favorites_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Screen displaying user's favorite experiences
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}
class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Load favorites on screen initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider).value;
      if (user != null) {
        ref.read(favoritesProvider.notifier).loadFavorites(user.favorites);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.error}'),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () {
                          final user = ref.read(currentUserProvider).value;
                          if (user != null) {
                            ref.read(favoritesProvider.notifier).loadFavorites(user.favorites);
                          }
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : state.favorites.isEmpty
                  ? EmptyFavoritesWidget(
                      onExplore: () {
                        // Navigate to explore/home
                        Navigator.pop(context);
                      },
                    )
                  : _buildFavoritesList(state),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: AppColors.textPrimary,
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Favorites',
        style: AppTypography.headlineSmall,
      ),
      centerTitle: false,
    );
  }

  Widget _buildFavoritesList(FavoritesState state) {
    return CustomScrollView(
      slivers: [
        // Grid of favorite experiences
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: AppSpacing.lg,
              mainAxisSpacing: AppSpacing.lg,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final favorite = state.favorites[index];
                return ExperienceCard(
                  imageUrl: favorite.coverImage,
                  hostName: favorite.hostName,
                  hostAvatarUrl: favorite.hostPhotoUrl,
                  location: favorite.location.city,
                  price: 'LKR ${favorite.price.toStringAsFixed(0)}',
                  description: favorite.description,
                  rating: favorite.averageRating,
                  ratingCount: favorite.reviewCount,
                  isFavorite: true,
                  height: 320,
                  width: double.infinity,
                  onTap: () {
                    context.push('/experience/${favorite.id}');
                  },
                  onFavoriteTap: () {
                    ref.read(favoritesProvider.notifier)
                        .toggleFavorite(favorite.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${favorite.title} removed from favorites'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
              childCount: state.favorites.length,
            ),
          ),
        ),
      ],
    );
  }
}

/// Import EmptyFavoritesWidget if not already imported from core/widgets
extension on FavoritesScreen {
  // Helper extension if needed
}
