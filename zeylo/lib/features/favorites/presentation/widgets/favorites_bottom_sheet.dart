import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/experience_card.dart';
import '../providers/favorites_provider.dart';

/// Draggable bottom sheet displaying seeker's favorite experiences
class FavoritesBottomSheet extends ConsumerWidget {
  const FavoritesBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Text(
                      'My Favorites',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${state.favorites.length}',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Content
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.favorites.isEmpty
                        ? _buildEmptyState(context)
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                            itemCount: state.favorites.length,
                            itemBuilder: (context, index) {
                              final experience = state.favorites[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                                child: ExperienceCard(
                                  imageUrl: experience.coverImage,
                                  hostName: experience.hostName,
                                  hostAvatarUrl: experience.hostPhotoUrl,
                                  location: experience.location.city,
                                  price: 'LKR ${experience.price.toStringAsFixed(0)}',
                                  description: experience.description,
                                  title: experience.title,
                                  rating: experience.averageRating,
                                  ratingCount: experience.reviewCount,
                                  isFavorite: true,
                                  onTap: () {
                                    Navigator.pop(context);
                                    context.push('/experience/${experience.id}');
                                  },
                                  onFavoriteTap: () {
                                    ref.read(favoritesProvider.notifier).toggleFavorite(experience.id);
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 64,
            color: AppColors.textHint.withOpacity(0.3),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No favorites yet',
            style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Explore experiences and add them\nto your favorites',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMediumSecondary,
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: const Text('Start Exploring'),
          ),
        ],
      ),
    );
  }
}
