import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../providers/home_provider.dart';

/// Icon mapping for each category
const _categoryIcons = <String, IconData>{
  'food and drinks': Icons.local_dining,
  'food': Icons.local_dining,
  'culture': Icons.account_balance,
  'wellness': Icons.self_improvement,
  'nightlife': Icons.local_bar,
  'outdoor': Icons.hiking,
  'adventure': Icons.paragliding,
  'all': Icons.apps,
};

IconData _iconFor(String name) {
  return _categoryIcons[name.toLowerCase()] ?? Icons.category_outlined;
}

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
              height: 110,
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
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : AppSpacing.md,
                  ),
                  child: SizedBox(
                    width: 85,
                    child: ShimmerListTile(
                      height: 110,
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
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(selectedCategoryProvider) == category;
    final icon = _iconFor(category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    AppColors.primary.withOpacity(0.18),
                    AppColors.primaryLight.withOpacity(0.10),
                  ]
                : [
                    AppColors.primary.withOpacity(0.08),
                    AppColors.primaryLight.withOpacity(0.04),
                  ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? [
                          AppColors.primary.withOpacity(0.25),
                          AppColors.primaryLight.withOpacity(0.15),
                        ]
                      : [
                          AppColors.primary.withOpacity(0.12),
                          AppColors.primaryLight.withOpacity(0.06),
                        ],
                ),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.primaryDark : AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected
                      ? AppColors.primaryDark
                      : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
