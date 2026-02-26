import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Earnings stat card widget with colored background
class EarningsStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color backgroundColor;
  final Color textColor;

  const EarningsStatCard({
    required this.label,
    required this.value,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.textInverse,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: textColor.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTypography.headlineSmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
