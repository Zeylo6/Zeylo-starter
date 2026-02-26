import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Stats row widget showing followers, following, and posts
class ProfileStatsRow extends StatelessWidget {
  final int followers;
  final int following;
  final int posts;
  final VoidCallback? onFollowersPressed;
  final VoidCallback? onFollowingPressed;
  final VoidCallback? onPostsPressed;

  const ProfileStatsRow({
    required this.followers,
    required this.following,
    required this.posts,
    this.onFollowersPressed,
    this.onFollowingPressed,
    this.onPostsPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(
          label: 'followers',
          value: followers.toString(),
          onPressed: onFollowersPressed,
        ),
        _StatItem(
          label: 'following',
          value: following.toString(),
          onPressed: onFollowingPressed,
        ),
        _StatItem(
          label: 'Posts',
          value: posts.toString().padLeft(2, '0'),
          onPressed: onPostsPressed,
        ),
      ],
    );
  }
}

/// Individual stat item
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onPressed;

  const _StatItem({
    required this.label,
    required this.value,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Opacity(
        opacity: onPressed != null ? 1.0 : 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
