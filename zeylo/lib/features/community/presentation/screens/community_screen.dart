import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/community_provider.dart';
import '../widgets/community_post_card.dart';
import '../widgets/suggested_user_card.dart';
import '../widgets/moments_bar.dart';

/// Community screen displaying community posts feed
///
/// Features:
/// - Top bar with Z logo and action icons
/// - Suggested Explorers horizontal scroll
/// - Full-width community post cards
/// - Pull-to-refresh support
/// - FAB to create a post
class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-post'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.textInverse),
      ),
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

            // Moments (Stories)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: AppSpacing.md),
                child: MomentsBar(),
              ),
            ),

            // Community section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Text(
                  'Community',
                  style: AppTypography.headlineLarge,
                ),
              ),
            ),

            // Suggested Explorers section
            SliverToBoxAdapter(
              child: _buildSuggestedExplorers(),
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
                          'Be the first to share your experience!',
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
                    child: ShimmerListTile(height: 350),
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
                      error.toString(),
                      style: AppTypography.bodyMediumSecondary,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                      onPressed: () => ref.refresh(communityPostsProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('Retry', style: TextStyle(color: AppColors.textInverse)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
  }

  Widget _buildSuggestedExplorers() {
    final currentUser = ref.watch(currentUserProvider).value;
    if (currentUser == null) return const SizedBox.shrink();

    return ref.watch(suggestedUsersProvider(currentUser.uid)).when(
          data: (suggestions) {
            if (suggestions.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    'Suggested Explorers',
                    style: AppTypography.titleMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 190,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    scrollDirection: Axis.horizontal,
                    itemCount: suggestions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      return SuggestedUserCard(
                        user: suggestions[index],
                        currentUserId: currentUser.uid,
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: ShimmerListTile(height: 190),
          ),
          error: (error, _) => const SizedBox.shrink(),
        );
  }

  Future<void> _onRefresh() async {
    // StreamProvider auto-updates; just give visual feedback
    await Future.delayed(const Duration(milliseconds: 800));
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
    context.push('/post-comments/$postId');
  }

  void _sharePost(String postId) {
    Share.share(
      'Check out this post on Zeylo: https://zeylolk.netlify.app/community/post/$postId',
      subject: 'New Zeylo Post',
    );
  }
}

/// Top bar widget
class _TopBar extends StatelessWidget {
  const _TopBar({super.key});

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
              onPressed: () {
                Share.share(
                  'Explore Zeylo Community: https://zeylolk.netlify.app/community',
                  subject: 'Zeylo Community',
                );
              },
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ],
    );
  }
}
