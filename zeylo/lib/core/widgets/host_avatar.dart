import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// HostAvatar widget displaying host profile image with optional badges
///
/// Features:
/// - Circular avatar with CachedNetworkImage
/// - Size parameter (small: 32, medium: 48, large: 80)
/// - Optional verified badge (small purple checkmark overlay)
/// - Optional "Superhost" label below
/// - Fallback to initials on no image
/// - Optional online indicator (green dot)
///
/// Example:
/// ```dart
/// HostAvatar(
///   imageUrl: 'https://example.com/avatar.jpg',
///   hostName: 'John Doe',
///   size: AvatarSize.large,
///   isVerified: true,
///   isSuperhost: true,
///   isOnline: true,
/// )
/// ```
class HostAvatar extends StatelessWidget {
  /// Avatar image URL
  final String? imageUrl;

  /// Host name (for initials fallback and superhost label)
  final String hostName;

  /// Avatar size
  final AvatarSize size;

  /// Whether the host is verified
  final bool isVerified;

  /// Whether the host is a superhost
  final bool isSuperhost;

  /// Whether the host is currently online
  final bool isOnline;

  const HostAvatar({
    this.imageUrl,
    required this.hostName,
    this.size = AvatarSize.medium,
    this.isVerified = false,
    this.isSuperhost = false,
    this.isOnline = false,
    Key? key,
  }) : super(key: key);

  double get _avatarSize {
    return switch (size) {
      AvatarSize.small => 32,
      AvatarSize.medium => 48,
      AvatarSize.large => 80,
    };
  }

  double get _badgeSize {
    return switch (size) {
      AvatarSize.small => 12,
      AvatarSize.medium => 16,
      AvatarSize.large => 24,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            // Avatar circle
            Container(
              width: _avatarSize,
              height: _avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: _buildAvatarContent(),
              ),
            ),
            // Verified badge (top-right)
            if (isVerified)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: _badgeSize,
                  height: _badgeSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      size: _badgeSize * 0.6,
                      color: AppColors.textInverse,
                    ),
                  ),
                ),
              ),
            // Online indicator (bottom-right)
            if (isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: _badgeSize,
                  height: _badgeSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.onlineIndicator,
                    border: Border.fromBorderSide(
                      BorderSide(color: AppColors.background, width: 2),
                    ),
                  ),
                ),
              ),
          ],
        ),
        // Superhost label
        if (isSuperhost) ...[
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              'Superhost',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvatarContent() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.surface,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildInitialsAvatar(),
      );
    }

    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    final names = hostName.split(' ');
    final initials = (names.isNotEmpty ? names[0][0] : '')
        .toUpperCase() +
        (names.length > 1 ? names[1][0].toUpperCase() : '');

    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Center(
        child: Text(
          initials,
          style: switch (size) {
            AvatarSize.small => AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            AvatarSize.medium => AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            AvatarSize.large => AppTypography.headlineSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
          },
        ),
      ),
    );
  }
}

/// Avatar size enumeration
enum AvatarSize {
  small,
  medium,
  large,
}
