import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Match badge widget
///
/// Displays a percentage match badge for mood-matched experiences.
/// Shows percentage with color coding:
/// - Green (90%+)
/// - Yellow (70-89%)
/// - Red (Below 70%)
///
/// Example:
/// ```dart
/// MatchBadge(matchPercentage: 98)
/// ```
class MatchBadgeWidget extends StatelessWidget {
  /// Match percentage (0-100)
  final int matchPercentage;

  /// Optional custom text (defaults to percentage)
  final String? customText;

  const MatchBadgeWidget({
    required this.matchPercentage,
    this.customText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = _getBadgeColor();
    final displayText = customText ?? '$matchPercentage% Match';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        border: Border.all(color: badgeColor, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            displayText,
            style: AppTypography.labelSmall.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Get badge color based on match percentage
  Color _getBadgeColor() {
    if (matchPercentage >= 90) {
      return AppColors.success;
    } else if (matchPercentage >= 70) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }
}
