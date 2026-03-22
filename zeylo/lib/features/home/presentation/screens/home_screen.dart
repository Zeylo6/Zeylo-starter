import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/experience_card.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/category_chip_list.dart';
import '../../../../core/widgets/role_capsule.dart';
import '../../../messaging/presentation/providers/messaging_provider.dart';

/// Home screen of the Zeylo application
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late RefreshController _refreshController;
  bool _fabExpanded = false;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final isHost = currentUserAsync.value?.role == UserRole.host;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        edgeOffset: 80,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Glassmorphism top bar
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
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background.withOpacity(0.7),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.4),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              title: const _TopBar(),
              centerTitle: false,
            ),
            // Main content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    // Search bar
                    const HomeSearchBar(),
                    const SizedBox(height: AppSpacing.xxl),
                    // Category chips
                    const _CategorySection(),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
            // Experiences list
            _buildExperiencesList(),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.huge)),
          ],
        ),
      ),
      floatingActionButton: _buildSpeedDial(context, isHost),
    );
  }

  Widget _buildSpeedDial(BuildContext context, bool isHost) {
    final items = [
      if (isHost)
        _SpeedDialItem(
          heroTag: 'create_experience',
          icon: Icons.add_rounded,
          label: 'Create Experience',
          color: AppColors.success,
          onTap: () {
            setState(() => _fabExpanded = false);
            context.push('/create-experience');
          },
        ),
      _SpeedDialItem(
        heroTag: 'create_chain',
        icon: Icons.link_rounded,
        label: 'Create Chain',
        color: AppColors.secondary,
        onTap: () {
          setState(() => _fabExpanded = false);
          context.push('/chain/create', extra: {'userId': 'user_1'});
        },
      ),
      _SpeedDialItem(
        heroTag: 'surprise_me',
        icon: Icons.card_giftcard_rounded,
        label: 'Surprise Me',
        color: AppColors.primary,
        onTap: () {
          setState(() => _fabExpanded = false);
          context.push('/mystery/create', extra: {'userId': 'user_1'});
        },
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return AnimatedSlide(
            duration: Duration(milliseconds: 150 + index * 60),
            curve: Curves.easeOutBack,
            offset: _fabExpanded ? Offset.zero : const Offset(0, 0.5),
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 150 + index * 60),
              opacity: _fabExpanded ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: item.color.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FloatingActionButton.extended(
                        heroTag: item.heroTag,
                        onPressed: _fabExpanded ? item.onTap : null,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        highlightElevation: 0,
                        icon: Icon(item.icon, color: Colors.white),
                        label: Text(
                          item.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.xs),
        // Main toggle FAB with glow
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (_fabExpanded ? AppColors.error : AppColors.primary)
                    .withOpacity(0.35),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            heroTag: 'main_fab_toggle',
            onPressed: () => setState(() => _fabExpanded = !_fabExpanded),
            backgroundColor:
                _fabExpanded ? AppColors.error : AppColors.primary,
            elevation: 0,
            child: AnimatedRotation(
              turns: _fabExpanded ? 0.125 : 0,
              duration: const Duration(milliseconds: 250),
              child: Icon(
                _fabExpanded ? Icons.close_rounded : Icons.add_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExperiencesList() {
    return ref.watch(experiencesByFilterProvider).when(
          data: (experiences) {
            if (experiences.isEmpty) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.08),
                          ),
                          child: Icon(
                            Icons.search_off_rounded,
                            size: 36,
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'No experiences found',
                          style: AppTypography.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Try adjusting your search or filters',
                          style: AppTypography.bodyMediumSecondary,
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
                    final experience = experiences[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                      child: ExperienceCard(
                        heroTag: 'home_experience_${experience.id}',
                        title: experience.title,
                        imageUrl: experience.coverImage,
                        hostName: experience.hostName,
                        hostAvatarUrl: experience.hostPhotoUrl,
                        isHostVerified: experience.isHostVerified,
                        location:
                            '${experience.location.city}, ${experience.location.country}',
                        price:
                            'Rs. ${experience.price.toStringAsFixed(0)}',
                        description: experience.shortDescription,
                        rating: experience.averageRating,
                        isFavorite:
                            ref.watch(isFavoritedProvider(experience.id)),
                        onTap: () => _navigateToDetail(experience.id),
                        onFavoriteTap: () =>
                            _toggleFavorite(experience.id),
                        onMessageTap: () => _messageHost(
                            experience.hostId, experience.hostName),
                      ),
                    );
                  },
                  childCount: experiences.length,
                ),
              ),
            );
          },
          loading: () => SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  child: const ShimmerExperienceCard(height: 340),
                ),
                childCount: 3,
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
                      Icons.error_outline_rounded,
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
    ref.refresh(featuredExperiencesProvider);
    ref.refresh(categoriesProvider);
    await Future.delayed(const Duration(seconds: 1));
  }

  void _navigateToDetail(String experienceId) {
    context.push('/experience/$experienceId');
  }

  void _toggleFavorite(String experienceId) {
    final isFavorited = ref.read(isFavoritedProvider(experienceId));
    ref.read(favoritesProvider.notifier).toggleFavorite(experienceId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            isFavorited ? 'Removed from favorites' : 'Added to favorites'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _messageHost(String hostId, String hostName) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to message hosts')),
      );
      return;
    }

    if (currentUser.uid == hostId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot message yourself')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting conversation...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final conversation = await ref.read(
        getOrCreateConversationProvider((currentUser.uid, hostId)).future,
      );

      if (mounted) {
        context.push('/chat/${conversation.id}', extra: {
          'otherUserName': hostName,
          'currentUserId': currentUser.uid,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting conversation: $e')),
        );
      }
    }
  }
}

/// Glassmorphism top bar with logo and action icons
class _TopBar extends ConsumerWidget {
  const _TopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final role = user?.role ?? UserRole.seeker;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo with glow effect
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
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
            RoleCapsule(role: role),
            const SizedBox(width: AppSpacing.sm),
            // Glassy icon button
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.45),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, size: 20),
                    onPressed: () {
                      final currentUser =
                          fb_auth.FirebaseAuth.instance.currentUser;
                      if (currentUser != null) {
                        context.push('/messages', extra: {
                          'userId': currentUser.uid,
                          'userName': 'Messages',
                        });
                      }
                    },
                    color: AppColors.textPrimary,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Category section widget
class _CategorySection extends ConsumerWidget {
  const _CategorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: AppTypography.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        const CategoryChipList(),
      ],
    );
  }
}

class RefreshController {
  void dispose() {}
}

/// Data class for speed-dial FAB items
class _SpeedDialItem {
  final String heroTag;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SpeedDialItem({
    required this.heroTag,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
