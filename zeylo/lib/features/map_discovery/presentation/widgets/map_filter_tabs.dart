import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/map_provider.dart';

/// Widget displaying filter chips for map types
class MapFilterTabs extends StatelessWidget {
  /// Available filter types
  final List<MapFilterType> filters;

  /// Currently active filter
  final MapFilterType activeFilter;

  /// Callback when filter is selected
  final Function(MapFilterType) onFilterChanged;

  const MapFilterTabs({
    required this.filters,
    required this.activeFilter,
    required this.onFilterChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final filter in filters)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: _FilterChip(
                  label: filter.displayText,
                  isActive: activeFilter == filter,
                  onTap: () => onFilterChanged(filter),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Individual filter chip widget
class _FilterChip extends StatelessWidget {
  /// Label text
  final String label;

  /// Whether this chip is active
  final bool isActive;

  /// Callback when tapped
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isActive ? AppColors.textInverse : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
