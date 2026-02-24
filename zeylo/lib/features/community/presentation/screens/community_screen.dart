import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../providers/community_provider.dart';
import '../widgets/community_post_card.dart';

/// Community screen displaying community posts feed
///
/// Features:
/// - Top bar with Z logo and action icons
/// - "Community" section label
/// - Full-width community post cards
/// - Pull-to-refresh support
/// - Bottom navigation visible
class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // Top bar
            SliverAppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              floating: true,
              snap: true,
              pinned: false,
              toolbarHeight: 56,
              title: const _TopBar(),
            ),

            // Community section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: Text(
                  'Community',
                  style: AppTypography.headlineLarge,
                ),
              ),
            ),

            // Posts feed
            _buildPostsFeed(),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsFeed() {
    return ref.watch(communityPostsProvider).when(
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
                          Icons.forum_outlined,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'No posts yet',
                          style: AppTypography.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Be the first to share your experience',
                          style: AppTypography.bodyMediumSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = posts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: CommunityPostCard(
                        post: post,
                        onLikeTap: () => _toggleLike(post.id),
                        onCommentTap: () => _navigateToComments(post.id),
                        onShareTap: () => _sharePost(post.id),
                      ),
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
                    child: ShimmerListTile(
                      height: 350,
                    ),
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
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Please try again later',
                      style: AppTypography.bodyMediumSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
  }

  Future<void> _onRefresh() async {
    ref.refresh(communityPostsProvider);
    await Future.delayed(const Duration(seconds: 1));
  }

  void _toggleLike(String postId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post liked'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToComments(String postId) {
    Navigator.of(context).pushNamed(
      '/post-comments',
      arguments: postId,
    );
  }

  void _sharePost(String postId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post shared'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Top bar widget
class _TopBar extends StatelessWidget {
  const _TopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Center(
            child: Text(
              'Z',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textInverse,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
        // Action icons
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.send_outlined),
              onPressed: () {},
              color: AppColors.textPrimary,
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {},
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ],
    );
  }
}
