import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Card displaying host information in experience detail
///
/// Shows:
/// - Host avatar
/// - Host name
/// - Rating and review count
/// - Host bio
/// - Message button
class HostInfoCard extends StatelessWidget {
  /// Host name
  final String hostName;

  /// Host avatar URL
  final String hostPhotoUrl;

  /// Host rating
  final double rating;

  /// Number of reviews
  final int reviewCount;

  /// Host bio/description
  final String bio;

  /// Callback when message button is tapped
  final VoidCallback? onMessageTap;

  const HostInfoCard({
    required this.hostName,
    required this.hostPhotoUrl,
    required this.rating,
    required this.reviewCount,
    required this.bio,
    this.onMessageTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar and name
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: CachedNetworkImage(
                    imageUrl: hostPhotoUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: AppColors.surface),
                    errorWidget: (context, url, error) =>
                        Container(color: AppColors.surface),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Name and rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hostName,
                      style: AppTypography.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    // Rating
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Color(0xFFFDB022),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$rating',
                          style: AppTypography.labelMedium,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '($reviewCount reviews)',
                          style: AppTypography.bodySmallSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Bio
          Text(
            bio,
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Message button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: InkWell(
                onTap: onMessageTap,
                child: Center(
                  child: Text(
                    'Message Host',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textInverse,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
