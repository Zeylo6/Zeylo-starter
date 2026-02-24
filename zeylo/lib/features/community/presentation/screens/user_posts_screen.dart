import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../providers/community_provider.dart';
import '../widgets/post_feed_item.dart';

/// User posts screen displaying a user's post feed
///
/// Features:
/// - User avatar and name at top
/// - "Posts" label
/// - Feed of user's posts
/// - Each post shows: user info, image, like button, caption with tags, timestamp
class UserPostsScreen extends ConsumerWidget {
  /// User ID to display posts for
  final String userId;

  /// User name (optional, can be fetched from data)
  final String? userName;

  /// User avatar URL (optional, can be fetched from data)
  final String? userAvatarUrl;

  const UserPostsScreen({
    required this.userId,
    this.userName,
    this.userAvatarUrl,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          color: AppColors.textPrimary,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // User header
          if (userName != null || userAvatarUrl != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User avatar
                    if (userAvatarUrl != null)
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                          child: CachedNetworkImage(
                            imageUrl: userAvatarUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.surface,
                            ),
                            errorWidget: (context, url, error) =>
                                Container(color: AppColors.surface),
                          ),
                        ),
                      ),
                    if (userAvatarUrl != null)
                      const SizedBox(height: AppSpacing.md),
                    // User name and Posts label
                    if (userName != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName!,
                            style: AppTypography.headlineLarge,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Posts',
                            style: AppTypography.bodyMediumSecondary,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

          // Posts feed
          _buildUserPostsFeed(ref),
        ],
      ),
    );
  }

  Widget _buildUserPostsFeed(WidgetRef ref) {
    return ref.watch(userPostsProvider(userId)).when(
          data: (posts) {
            if (posts.isEmpty) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'No posts yet',
                          style: AppTypography.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = posts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: PostFeedItem(post: post),
                    );
                  },
                  childCount: posts.length,
                ),
              ),
            );
          },
          loading: () => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: ShimmerListTile(height: 300),
                  ),
                ),
              ),
            ),
          ),
          error: (error, stackTrace) => SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Something went wrong',
                      style: AppTypography.headlineSmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
  }
}
