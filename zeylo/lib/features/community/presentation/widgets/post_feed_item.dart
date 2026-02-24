import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../domain/entities/post_entity.dart';

/// Individual post item in a feed
///
/// Compact post display with:
/// - User info (avatar and name)
/// - Post image
/// - Like button and count
/// - Caption with tags
/// - Timestamp
class PostFeedItem extends StatefulWidget {
  /// The post to display
  final Post post;

  /// Callback when post is tapped
  final VoidCallback? onTap;

  /// Callback when like button is tapped
  final VoidCallback? onLikeTap;

  const PostFeedItem({
    required this.post,
    this.onTap,
    this.onLikeTap,
    Key? key,
  }) : super(key: key);

  @override
  State<PostFeedItem> createState() => _PostFeedItemState();
}

class _PostFeedItemState extends State<PostFeedItem> {
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _isLiked = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          _buildUserInfo(),
          const SizedBox(height: AppSpacing.md),

          // Post image
          if (widget.post.images.isNotEmpty)
            _buildPostImage(),
          if (widget.post.images.isNotEmpty)
            const SizedBox(height: AppSpacing.md),

          // Like button
          _buildLikeButton(),
          const SizedBox(height: AppSpacing.sm),

          // Caption
          _buildCaption(),
          const SizedBox(height: AppSpacing.sm),

          // Timestamp
          Text(
            _formatDate(widget.post.createdAt),
            style: AppTypography.bodySmallSecondary,
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Divider(
              color: AppColors.border,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        // Avatar
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: CachedNetworkImage(
              imageUrl: widget.post.userAvatar,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: AppColors.surface),
              errorWidget: (context, url, error) =>
                  Container(color: AppColors.surface),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Name
        Text(
          widget.post.userName,
          style: AppTypography.titleMedium,
        ),
      ],
    );
  }

  Widget _buildPostImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: CachedNetworkImage(
          imageUrl: widget.post.images.first,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const ShimmerListTile(height: 200),
          errorWidget: (context, url, error) => Container(
            color: AppColors.surface,
            child: const Icon(Icons.image_not_supported),
          ),
        ),
      ),
    );
  }

  Widget _buildLikeButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isLiked = !_isLiked;
        });
        widget.onLikeTap?.call();
      },
      child: Row(
        children: [
          Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            color: _isLiked ? AppColors.error : AppColors.textSecondary,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.post.likesCount}',
            style: AppTypography.bodySmall.copyWith(
              color: _isLiked
                  ? AppColors.error
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.post.caption,
          style: AppTypography.bodyMedium,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.post.tags.isNotEmpty || widget.post.experienceTag != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Wrap(
              spacing: AppSpacing.sm,
              children: [
                ...widget.post.tags.map(
                  (tag) => Text(
                    tag,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (widget.post.experienceTag != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      widget.post.experienceTag!,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
