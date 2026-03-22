import 'dart:ui';
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
  'all': Icons.apps_rounded,
};

IconData _iconFor(String name) {
  return _categoryIcons[name.toLowerCase()] ?? Icons.category_outlined;
}

/// Horizontal scrollable list of glassmorphism category chips
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

/// Glassmorphism category chip widget
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 85,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? [
                          AppColors.primary.withOpacity(0.25),
                          AppColors.gradientEnd.withOpacity(0.15),
                        ]
                      : [
                          Colors.white.withOpacity(0.55),
                          Colors.white.withOpacity(0.35),
                        ],
                ),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.5)
                      : Colors.white.withOpacity(0.6),
                  width: isSelected ? 1.8 : 1.2,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isSelected
                            ? [
                                AppColors.primary.withOpacity(0.3),
                                AppColors.gradientEnd.withOpacity(0.2),
                              ]
                            : [
                                AppColors.primary.withOpacity(0.1),
                                AppColors.primaryLight.withOpacity(0.08),
                              ],
                      ),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.3)
                            : Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: isSelected
                          ? AppColors.primaryDark
                          : AppColors.primary,
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
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
