import 'dart:ui';
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

/// Glassmorphism profile header widget
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

    final isFollowing = !isCurrentUser && currentUserId != null
        ? ref.watch(isFollowingProvider((currentUserId, profile.id))).value ??
            false
        : false;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.55),
                  Colors.white.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              border: Border.all(
                color: Colors.white.withOpacity(0.65),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile photo with glow
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: HostAvatar(
                    imageUrl: profile.photoUrl,
                    hostName: profile.name,
                    size: AvatarSize.large,
                    isVerified: profile.isVerified,
                    isSuperhost: profile.isSuperhost,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Name
                Text(
                  profile.name,
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),

                // Verified badge
                if (profile.isHostVerified) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.12),
                              AppColors.gradientEnd.withOpacity(0.06),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_rounded,
                                color: AppColors.primary, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Verified Host',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),

                // Stats row
                ProfileStatsRow(
                  followers: profile.followerCount,
                  following: profile.followingCount,
                  posts: profile.postCount,
                  rating: profile.averageRating,
                  reviews: profile.ratingCount,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Action buttons
                if (isCurrentUser)
                  _buildGlassEditButton(context)
                else if (currentUserId != null)
                  Row(
                    children: [
                      Expanded(
                        child: _buildGlassFollowButton(
                            ref, currentUserId, isFollowing),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _buildGlassMessageButton(
                            context, ref, currentUserId),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassEditButton(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.12),
                AppColors.gradientEnd.withOpacity(0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1.2,
            ),
          ),
          child: TextButton(
            onPressed: onEditPressed,
            child: Text(
              'Edit Profile',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassFollowButton(
      WidgetRef ref, String currentUserId, bool isFollowing) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: isFollowing
                ? LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.55),
                      Colors.white.withOpacity(0.3),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.8),
                      AppColors.gradientEnd.withOpacity(0.65),
                    ],
                  ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isFollowing
                  ? Colors.white.withOpacity(0.6)
                  : Colors.white.withOpacity(0.3),
              width: 1.2,
            ),
            boxShadow: [
              if (!isFollowing)
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: TextButton(
            onPressed: () {
              ref.read(followActionProvider(
                  (currentUserId, profile.id, !isFollowing)));
            },
            child: Text(
              isFollowing ? 'Following' : 'Follow',
              style: AppTypography.labelLarge.copyWith(
                color: isFollowing ? AppColors.textPrimary : Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassMessageButton(
      BuildContext context, WidgetRef ref, String currentUserId) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.55),
                Colors.white.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.25),
              width: 1.2,
            ),
          ),
          child: TextButton.icon(
            onPressed: () async {
              final result = await ref.read(
                getOrCreateConversationProvider((currentUserId, profile.id))
                    .future,
              );
              if (context.mounted) {
                context.push('/chat/${result.id}', extra: {
                  'otherUserName': profile.name,
                  'currentUserId': currentUserId,
                });
              }
            },
            icon: Icon(Icons.send_rounded, size: 16, color: AppColors.primary),
            label: Text(
              'Message',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
