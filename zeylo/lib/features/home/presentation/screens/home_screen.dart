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

/// Home screen with full glassmorphism aesthetic
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3EEFF), // soft purple tint
              Color(0xFFF9F7FF), // near-white purple
              Color(0xFFEDE9FE), // lavender
              Color(0xFFF5F3FF), // lightest purple
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Decorative gradient orbs for depth
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.12),
                      AppColors.primary.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 300,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gradientEnd.withOpacity(0.08),
                      AppColors.gradientEnd.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withOpacity(0.1),
                      AppColors.secondary.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Main scrollable content
            RefreshIndicator(
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
                    toolbarHeight: 68,
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
                    centerTitle: false,
                  ),
                  // Greeting + Search + Categories
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
                          // Category section with glass header
                          const _CategorySection(),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),
                  // Experiences list
                  _buildExperiencesList(),
                  const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.huge)),
                ],
              ),
            ),
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
            duration: Duration(milliseconds: 180 + index * 70),
            curve: Curves.easeOutBack,
            offset: _fabExpanded ? Offset.zero : const Offset(0, 0.5),
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 180 + index * 70),
              opacity: _fabExpanded ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            item.color.withOpacity(0.8),
                            item.color.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: item.color.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: _fabExpanded ? item.onTap : null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(item.icon, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              item.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
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
        // Main FAB with glow
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (_fabExpanded ? AppColors.error : AppColors.primary)
                    .withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 3,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: FloatingActionButton(
                heroTag: 'main_fab_toggle',
                onPressed: () => setState(() => _fabExpanded = !_fabExpanded),
                backgroundColor: (_fabExpanded ? AppColors.error : AppColors.primary)
                    .withOpacity(0.9),
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.xxxl),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.6),
                                Colors.white.withOpacity(0.3),
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(AppRadius.xxl),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary.withOpacity(0.15),
                                      AppColors.gradientEnd
                                          .withOpacity(0.1),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.search_off_rounded,
                                  size: 36,
                                  color: AppColors.primary.withOpacity(0.6),
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
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.xl),
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
        // Logo with intense glow
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
              BoxShadow(
                color: AppColors.gradientEnd.withOpacity(0.2),
                blurRadius: 24,
                spreadRadius: -2,
                offset: const Offset(0, 8),
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
        // Action icons
        Row(
          children: [
            RoleCapsule(role: role),
            const SizedBox(width: AppSpacing.sm),
            // Glass message button
            _GlassIconButton(
              icon: Icons.send_rounded,
              onTap: () {
                final currentUser =
                    fb_auth.FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  context.push('/messages', extra: {
                    'userId': currentUser.uid,
                    'userName': 'Messages',
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// Reusable glass icon button
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 20, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

/// Category section with glass label
class _CategorySection extends ConsumerWidget {
  const _CategorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Categories',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
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
