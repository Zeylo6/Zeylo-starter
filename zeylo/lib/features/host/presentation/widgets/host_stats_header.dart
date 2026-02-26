import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/host_avatar.dart';
import '../../domain/entities/host_stats_entity.dart';

/// Host stats header widget with gradient background
class HostStatsHeader extends StatelessWidget {
  final String hostName;
  final String? hostPhotoUrl;
  final bool isSuperhost;
  final double thisMonthEarnings;
  final double averageRating;
  final HostStatsEntity stats;

  const HostStatsHeader({
    required this.hostName,
    this.hostPhotoUrl,
    this.isSuperhost = false,
    required this.thisMonthEarnings,
    required this.averageRating,
    required this.stats,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Host info row
            Row(
              children: [
                HostAvatar(
                  imageUrl: hostPhotoUrl,
                  hostName: hostName,
                  size: AvatarSize.medium,
                  isSuperhost: isSuperhost,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hostName,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textInverse,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (isSuperhost)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textInverse.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            'Superhost',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textInverse,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Stats cards row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatCard(
                  label: 'This Month',
                  value: '\$${thisMonthEarnings.toStringAsFixed(0)}',
                ),
                _StatCard(
                  label: 'Avg Rating',
                  value: averageRating.toStringAsFixed(1),
                ),
                _StatCard(
                  label: 'Avg Rating',
                  value: averageRating.toStringAsFixed(1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual stat card
class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.textInverse.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textInverse,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textInverse.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
