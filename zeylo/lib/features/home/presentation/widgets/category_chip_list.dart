import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../providers/home_provider.dart';

/// Horizontal scrollable list of category chips
///
/// Displays all available categories with icons and allows selection
class CategoryChipList extends ConsumerWidget {
  const CategoryChipList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(categoriesProvider).when(
          data: (categories) {
            return SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 0 : AppSpacing.md,
                      right: index == categories.length - 1
                          ? AppSpacing.md
                          : 0,
                    ),
                    child: _CategoryChip(
                      category: category.name,
                      imageUrl: category.imageUrl,
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).state =
                            category.name;
                      },
                    ),
                  );
                },
              ),
            );
          },
          loading: () => SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : AppSpacing.md,
                  ),
                  child: SizedBox(
                    width: 80,
                    child: ShimmerListTile(
                      height: 100,
                      showAvatar: false,
                    ),
                  ),
                );
              },
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Text(
              'Failed to load categories',
              style: AppTypography.bodySmallSecondary,
            ),
          ),
        );
  }
}

/// Individual category chip widget
class _CategoryChip extends ConsumerWidget {
  final String category;
  final String imageUrl;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.imageUrl,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected =
        ref.watch(selectedCategoryProvider) == category;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.card,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.surface,
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surface,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            // Dark overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            // Category name
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textInverse,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
