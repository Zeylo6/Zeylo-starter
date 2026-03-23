import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/host_avatar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../messaging/presentation/providers/messaging_provider.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../providers/profile_provider.dart';
import 'profile_stats_row.dart';

/// Profile header widget displaying user information
class ProfileHeader extends ConsumerWidget {
  final UserProfileEntity profile;
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    required this.profile,
    this.onEditPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserProvider).value?.uid;
    final isCurrentUser = currentUserId == profile.id;

    // Watch follow status only if not current user
    final isFollowing = !isCurrentUser && currentUserId != null
        ? ref.watch(isFollowingProvider((currentUserId, profile.id))).value ??
            false
        : false;

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
                  const Icon(Icons.verified,
                      color: AppColors.primary, size: 14),
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
            rating: profile.averageRating,
            reviews: profile.ratingCount,
          ),
          const SizedBox(height: AppSpacing.md),

          // Edit Profile or Follow + Message buttons
          if (isCurrentUser)
            _buildEditButton(context)
          else if (currentUserId != null)
            Row(
              children: [
                Expanded(
                  child: _buildFollowButton(ref, currentUserId, isFollowing),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildMessageButton(context, ref, currentUserId),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return SizedBox(
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
    );
  }

  Widget _buildFollowButton(
      WidgetRef ref, String currentUserId, bool isFollowing) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          ref.read(
              followActionProvider((currentUserId, profile.id, !isFollowing)));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing ? AppColors.surface : AppColors.primary,
          foregroundColor:
              isFollowing ? AppColors.textPrimary : AppColors.textInverse,
          elevation: 0,
          side: isFollowing ? BorderSide(color: AppColors.border) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Text(
          isFollowing ? 'Following' : 'Follow',
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageButton(
      BuildContext context, WidgetRef ref, String currentUserId) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () async {
          final result = await ref.read(
            getOrCreateConversationProvider((currentUserId, profile.id)).future,
          );
          if (context.mounted) {
            context.push('/chat/${result.id}', extra: {
              'otherUserName': profile.name,
              'currentUserId': currentUserId,
            });
          }
        },
        icon: const Icon(Icons.send_outlined, size: 18),
        label: Text(
          'Message',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }
}
