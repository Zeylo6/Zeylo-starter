import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Stats row widget showing followers, following, and posts
class ProfileStatsRow extends StatelessWidget {
  final int followers;
  final int following;
  final int posts;
  final double? rating;
  final int? reviews;

  const ProfileStatsRow({
    required this.followers,
    required this.following,
    required this.posts,
    this.rating,
    this.reviews,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          value: _formatNumber(followers),
          label: 'Followers',
        ),
        _buildDivider(),
        _buildStatItem(
          value: _formatNumber(following),
          label: 'Following',
        ),
        _buildDivider(),
        _buildDivider(),
        _buildStatItem(
          value: _formatNumber(posts),
          label: 'Posts',
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    IconData? icon,
    Color? iconColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: AppColors.border,
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}
