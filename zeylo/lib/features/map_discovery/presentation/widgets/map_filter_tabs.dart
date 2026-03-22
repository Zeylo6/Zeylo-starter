import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/map_provider.dart';

/// Glassmorphism filter chips for map types
class MapFilterTabs extends StatelessWidget {
  final List<MapFilterType> filters;
  final MapFilterType activeFilter;
  final Function(MapFilterType) onFilterChanged;

  const MapFilterTabs({
    required this.filters,
    required this.activeFilter,
    required this.onFilterChanged,
    super.key,
  });

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
                child: _GlassFilterChip(
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

/// Glassmorphism filter chip
class _GlassFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _GlassFilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: isActive ? 14 : 8,
            sigmaY: isActive ? 14 : 8,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isActive
                    ? [
                        AppColors.primary.withOpacity(0.8),
                        AppColors.gradientEnd.withOpacity(0.65),
                      ]
                    : [
                        Colors.white.withOpacity(0.55),
                        Colors.white.withOpacity(0.3),
                      ],
              ),
              border: Border.all(
                color: isActive
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white.withOpacity(0.65),
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(AppRadius.full),
              boxShadow: [
                if (isActive)
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
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
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color:
                    isActive ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
