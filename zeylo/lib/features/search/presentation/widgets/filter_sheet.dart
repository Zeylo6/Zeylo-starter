import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/providers/home_provider.dart';

/// Filter bottom sheet widget
///
/// Features:
/// - Category filter (multi-select)
/// - Price range slider
/// - Rating filter
/// - Distance filter
/// - Apply and Reset buttons
class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late RangeValues _priceRange;
  double _minRating = 0;
  double _maxDistance = 50;

  @override
  void initState() {
    super.initState();
    _priceRange = const RangeValues(0, 10000);
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final priceRange = ref.watch(priceRangeProvider);
    final rating = ref.watch(selectedRatingProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: AppSpacing.lg + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: AppTypography.headlineLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Category filter
              _buildCategoryFilter(),
              const SizedBox(height: AppSpacing.xxl),

              // Price range filter
              _buildPriceFilter(priceRange),
              const SizedBox(height: AppSpacing.xxl),

              // Rating filter
              _buildRatingFilter(rating),
              const SizedBox(height: AppSpacing.xxl),

              // Distance filter
              _buildDistanceFilter(),
              const SizedBox(height: AppSpacing.xxl),

              // Action buttons
              Row(
                children: [
                  // Reset button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetFilters,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      child: Text(
                        'Reset',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Apply button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      child: Text(
                        'Apply',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textInverse,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTypography.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        ref.watch(categoriesProvider).when(
              data: (categories) {
                return Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: categories
                      .map(
                        (category) => FilterChip(
                          label: Text(category.name),
                          selected: ref.watch(selectedCategoryProvider) ==
                              category.name,
                          onSelected: (selected) {
                            ref
                                .read(selectedCategoryProvider.notifier)
                                .state = selected ? category.name : null;
                          },
                          backgroundColor: AppColors.surface,
                          selectedColor:
                              AppColors.primary.withOpacity(0.2),
                          side: BorderSide(
                            color: ref.watch(selectedCategoryProvider) ==
                                    category.name
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const Text('Loading categories...'),
              error: (error, stackTrace) => Text(
                'Error loading categories',
                style: AppTypography.bodySmallSecondary,
              ),
            ),
      ],
    );
  }

  Widget _buildPriceFilter(RangeValues priceRange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: AppTypography.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        RangeSlider(
          values: priceRange,
          min: 0,
          max: 10000,
          divisions: 100,
          labels: RangeLabels(
            '\$${priceRange.start.toStringAsFixed(0)}',
            '\$${priceRange.end.toStringAsFixed(0)}',
          ),
          onChanged: (values) {
            ref.read(priceRangeProvider.notifier).state = values;
          },
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '\$${priceRange.start.toStringAsFixed(0)} - \$${priceRange.end.toStringAsFixed(0)}',
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildRatingFilter(double? selectedRating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minimum Rating',
          style: AppTypography.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          children: [0.0, 3.0, 3.5, 4.0, 4.5, 5.0]
              .map(
                (rating) => FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: rating == 0
                            ? AppColors.textSecondary
                            : const Color(0xFFFDB022),
                      ),
                      const SizedBox(width: 4),
                      Text(rating == 0 ? 'All' : '$rating+'),
                    ],
                  ),
                  selected: ref.watch(selectedRatingProvider) == rating,
                  onSelected: (selected) {
                    ref.read(selectedRatingProvider.notifier).state =
                        selected ? rating : null;
                  },
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  side: BorderSide(
                    color: ref.watch(selectedRatingProvider) == rating
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDistanceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distance',
          style: AppTypography.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        Slider(
          value: _maxDistance,
          min: 0,
          max: 100,
          divisions: 20,
          label: '${_maxDistance.toStringAsFixed(0)} km',
          onChanged: (value) {
            setState(() {
              _maxDistance = value;
            });
          },
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Up to ${_maxDistance.toStringAsFixed(0)} km',
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }

  void _applyFilters() {
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    ref.read(selectedCategoryProvider.notifier).state = null;
    ref.read(priceRangeProvider.notifier).state = const RangeValues(0, 10000);
    ref.read(selectedRatingProvider.notifier).state = null;
    setState(() {
      _maxDistance = 50;
    });
  }
}
