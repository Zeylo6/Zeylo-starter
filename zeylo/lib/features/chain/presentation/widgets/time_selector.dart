import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/chain_entity.dart';

/// Time selector widget for chain duration
///
/// Displays selectable chips for:
/// - Half Day (4-6 hours)
/// - Full Day (8-10 hours)
/// - Weekend (2 days)
///
/// Example:
/// ```dart
/// TimeSelector(
///   selectedDuration: ChainDuration.fullDay,
///   onDurationSelected: (duration) {
///     setState(() => selectedDuration = duration);
///   },
/// )
/// ```
class TimeSelector extends StatelessWidget {
  /// Currently selected duration
  final ChainDuration selectedDuration;

  /// Callback when duration is selected
  final ValueChanged<ChainDuration> onDurationSelected;

  const TimeSelector({
    required this.selectedDuration,
    required this.onDurationSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Time Available',
          style: AppTypography.labelLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: ChainDuration.values.map((duration) {
            final isSelected = selectedDuration == duration;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () => onDurationSelected(duration),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                      horizontal: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.surface,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      children: [
                        Text(
                          duration.label,
                          style: AppTypography.labelMedium.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          duration.timeRange,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
