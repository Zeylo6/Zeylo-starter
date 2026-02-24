import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/chain_entity.dart';

/// Individual experience card within a chain
///
/// Displays:
/// - Numbered position (1, 2, 3 in purple circle)
/// - Experience title
/// - Duration with icon
/// - Price with icon
/// - Edit and Remove buttons
/// - Drag handle on right side
class ChainExperienceCard extends StatelessWidget {
  /// The experience to display
  final ChainExperience experience;

  /// Position number in the chain (1-based)
  final int position;

  /// Callback when edit is pressed
  final VoidCallback? onEdit;

  /// Callback when remove is pressed
  final VoidCallback? onRemove;

  /// Whether to show drag handle
  final bool showDragHandle;

  const ChainExperienceCard({
    required this.experience,
    required this.position,
    this.onEdit,
    this.onRemove,
    this.showDragHandle = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(
          left: BorderSide(
            color: AppColors.primary,
            width: 4,
          ),
          top: BorderSide(color: AppColors.border, width: 1),
          right: BorderSide(color: AppColors.border, width: 1),
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Position circle
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$position',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textInverse,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Experience details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    experience.title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Experience description (duration)
                  Text(
                    experience.isOvernight
                        ? 'Overnight experience'
                        : '${experience.duration.toStringAsFixed(1)} hours experience',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Duration and price chips
                  Row(
                    children: [
                      _buildChip(
                        experience.isOvernight
                            ? 'Overnight'
                            : '${experience.duration.toStringAsFixed(1)}h',
                        Icons.schedule,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildChip(
                        '\$${experience.price.toStringAsFixed(0)}',
                        Icons.attach_money,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Action buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                  ),
                if (onRemove != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (showDragHandle) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.drag_handle,
                color: AppColors.textHint,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.textSecondary,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
