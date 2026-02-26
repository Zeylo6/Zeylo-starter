import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Performance stats section widget
class PerformanceSection extends StatelessWidget {
  final double responseRate;
  final double acceptanceRate;
  final int totalBookings;

  const PerformanceSection({
    required this.responseRate,
    required this.acceptanceRate,
    required this.totalBookings,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.textPrimary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Performance',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Stats list
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: [
              _PerformanceStat(
                label: 'Response Rate',
                value: '${responseRate.toStringAsFixed(0)}%',
              ),
              const SizedBox(height: AppSpacing.md),
              _PerformanceStat(
                label: 'Acceptance Rate',
                value: '${acceptanceRate.toStringAsFixed(0)}%',
              ),
              const SizedBox(height: AppSpacing.md),
              _PerformanceStat(
                label: 'Total Bookings',
                value: totalBookings.toString(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Individual performance stat
class _PerformanceStat extends StatelessWidget {
  final String label;
  final String value;

  const _PerformanceStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
