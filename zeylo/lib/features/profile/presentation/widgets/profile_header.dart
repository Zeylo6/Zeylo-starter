import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/host_avatar.dart';
import '../../domain/entities/user_profile_entity.dart';
import 'profile_stats_row.dart';

/// Profile header widget displaying user information
class ProfileHeader extends StatelessWidget {
  final UserProfileEntity profile;
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    required this.profile,
    this.onEditPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile photo
          HostAvatar(
            imageUrl: profile.photoUrl,
            hostName: profile.name,
            size: AvatarSize.large,
            isVerified: profile.isVerified,
            isSuperhost: profile.isSuperhost,
          ),
          const SizedBox(height: AppSpacing.md),

          // Name
          Text(
            profile.name,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (profile.isHostVerified) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, color: AppColors.primary, size: 14),
                  const SizedBox(width: 4),
                  const Text(
                    'Verified Host',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),

          // Stats row
          ProfileStatsRow(
            followers: profile.followerCount,
            following: profile.followingCount,
            posts: profile.postCount,
          ),
          const SizedBox(height: AppSpacing.md),

          // Edit Profile button
          if (onEditPressed != null)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: onEditPressed,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  'Edit Profile',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
