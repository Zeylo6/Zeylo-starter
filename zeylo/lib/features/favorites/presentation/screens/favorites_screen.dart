import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/experience_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../providers/favorites_provider.dart';

/// Screen displaying user's favorite experiences
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Load favorites on screen initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoritesProvider.notifier).loadFavorites();
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
                  child: Text('Error: ${state.error}'),
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
                  imageUrl: favorite.imageUrl,
                  hostName: favorite.hostName,
                  hostAvatarUrl: favorite.hostAvatarUrl,
                  location: favorite.location,
                  price: favorite.price,
                  description: favorite.description,
                  rating: favorite.rating,
                  ratingCount: favorite.ratingCount,
                  isFavorite: true,
                  height: 320,
                  width: double.infinity,
                  onTap: () {
                    // Navigate to experience details
                  },
                  onFavoriteTap: () {
                    ref.read(favoritesProvider.notifier)
                        .removeFavorite(favorite.id);
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
