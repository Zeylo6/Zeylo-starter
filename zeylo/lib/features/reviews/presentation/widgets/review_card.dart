import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/rating_widget.dart';
import '../../domain/entities/review_entity.dart';

/// Review card widget for displaying individual review
class ReviewCard extends StatelessWidget {
  /// Review entity to display
  final ReviewEntity review;

  /// Optional callback when card is tapped
  final VoidCallback? onTap;

  /// Whether to show the full comment or truncated
  final bool showFullComment;

  const ReviewCard({
    required this.review,
    this.onTap,
    this.showFullComment = false,
    super.key,
  });

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final truncatedComment = review.comment.length > 150
        ? '${review.comment.substring(0, 150)}...'
        : review.comment;

    final displayComment = showFullComment ? review.comment : truncatedComment;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Name, Rating, Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // User Avatar
                      if (review.userPhotoUrl != null && review.userPhotoUrl!.isNotEmpty)
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(review.userPhotoUrl!),
                          onBackgroundImageError: (exception, stackTrace) {
                            // Fallback to initials
                          },
                        )
                      else
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            _getInitials(review.userName),
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.textInverse,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: AppSpacing.md),

                      // Name and Rating
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.userName,
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            RatingWidget(
                              rating: review.rating,
                              isInteractive: false,
                              starSize: 14,
                              spacing: AppSpacing.xs,
                              showRatingText: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Time
                Text(
                  _getTimeAgo(review.createdAt),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Comment
            if (displayComment.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayComment,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                    maxLines: showFullComment ? null : 3,
                    overflow: showFullComment ? TextOverflow.visible : TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),

            // Helpful action (optional)
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // Handle helpful tap
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.thumb_up_outlined,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Helpful',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }
}
