import 'dart:ui';
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

/// Glassmorphism community screen
class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3EEFF),
              Color(0xFFF9F7FF),
              Color(0xFFEDE9FE),
              Color(0xFFF5F3FF),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              left: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gradientEnd.withOpacity(0.1),
                      AppColors.gradientEnd.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 200,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.08),
                      AppColors.primary.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  // Glass top bar
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    floating: true,
                    snap: true,
                    pinned: false,
                    toolbarHeight: 64,
                    flexibleSpace: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.5),
                                Colors.white.withOpacity(0.3),
                              ],
                            ),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white.withOpacity(0.5),
                                width: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    title: const _TopBar(),
                  ),

                  // Moments
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: AppSpacing.md),
                      child: MomentsBar(),
                    ),
                  ),

                  // Community header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 22,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Community',
                            style: AppTypography.headlineLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Suggested Explorers
                  SliverToBoxAdapter(child: _buildSuggestedExplorers()),

                  // Posts feed
                  _buildPostsFeed(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: FloatingActionButton(
                onPressed: () => context.push('/create-post'),
                backgroundColor: AppColors.primary.withOpacity(0.9),
                elevation: 0,
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
            ),
          ),
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.xxxl),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.55),
                                Colors.white.withOpacity(0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.xxl),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withOpacity(0.08),
                                ),
                                child: Icon(Icons.forum_rounded, size: 32,
                                    color: AppColors.primary.withOpacity(0.5)),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text('No posts yet', style: AppTypography.headlineSmall),
                              const SizedBox(height: AppSpacing.sm),
                              Text('Be the first to share your experience!',
                                  style: AppTypography.bodyMediumSecondary),
                            ],
                          ),
                        ),
                      ),
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
                    Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Something went wrong', style: AppTypography.headlineSmall),
                    const SizedBox(height: AppSpacing.sm),
                    Text(error.toString(),
                        style: AppTypography.bodyMediumSecondary,
                        textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                      onPressed: () => ref.refresh(communityPostsProvider),
                      child: const Text('Retry'),
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
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Suggested Explorers',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                    ],
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

/// Glass top bar
class _TopBar extends StatelessWidget {
  const _TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo with glow
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Z',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontFamily: 'Inter',
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        // Glass action icons
        Row(
          children: [
            _GlassIconBtn(
              icon: Icons.send_rounded,
              onTap: () {},
            ),
            const SizedBox(width: AppSpacing.sm),
            _GlassIconBtn(
              icon: Icons.share_rounded,
              onTap: () {
                Share.share(
                  'Explore Zeylo Community: https://zeylolk.netlify.app/community',
                  subject: 'Zeylo Community',
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _GlassIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.6),
                  Colors.white.withOpacity(0.3),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.7),
                width: 1.2,
              ),
            ),
            child: Icon(icon, size: 20, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
