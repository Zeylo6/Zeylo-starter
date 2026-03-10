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
import '../widgets/home_search_bar.dart';
import '../widgets/category_chip_list.dart';

/// Home screen of the Zeylo application
///
/// Displays:
/// - Top bar with logo and action icons
/// - Search bar
/// - Category chips (scrollable)
/// - Featured experiences in a vertical list
/// - Pull-to-refresh support
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late RefreshController _refreshController;

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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // Top bar with logo and actions
              SliverAppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                floating: true,
                snap: true,
                pinned: false,
                toolbarHeight: 56,
                title: const _TopBar(),
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
                      const SizedBox(height: AppSpacing.lg),
                      // Category chips
                      const _CategorySection(),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
              // Experiences list
              _buildExperiencesList(),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isHost) ...[
            FloatingActionButton.extended(
              heroTag: 'create_experience',
              onPressed: () {
                context.push('/create-experience');
              },
              backgroundColor: AppColors.success,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Create Experience',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          FloatingActionButton.extended(
            heroTag: 'create_chain',
            onPressed: () {
              context.push(
                '/chain/create',
                extra: {'userId': 'user_1'},
              );
            },
            backgroundColor: AppColors.secondary,
            icon: const Icon(Icons.link, color: Colors.white),
            label: const Text(
              'Create Chain',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FloatingActionButton.extended(
            heroTag: 'surprise_me',
            onPressed: () {
              // Provide a dummy user ID or get it from auth provider
              context.push(
                '/mystery/create',
                extra: {'userId': 'user_1'}, // Using demo user ID for now
              );
            },
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.card_giftcard, color: Colors.white),
            label: const Text(
              'Surprise Me',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
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
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: AppColors.textSecondary,
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
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: ExperienceCard(
                        imageUrl: experience.coverImage,
                        hostName: experience.hostName,
                        hostAvatarUrl: experience.hostPhotoUrl,
                        location:
                            '${experience.location.city}, ${experience.location.country}',
                        price:
                            '\$${experience.price.toStringAsFixed(0)} ${experience.currency}',
                        description: experience.shortDescription,
                        rating: experience.averageRating,
                        ratingCount: experience.reviewCount,
                        onTap: () => _navigateToDetail(experience.id),
                        onFavoriteTap: () => _toggleFavorite(experience.id),
                      ),
                    );
                  },
                  childCount: experiences.length,
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
                      height: 300,
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
    ref.refresh(featuredExperiencesProvider);
    ref.refresh(categoriesProvider);
    await Future.delayed(const Duration(seconds: 1));
  }

  void _navigateToDetail(String experienceId) {
    // Navigate to experience detail screen
    context.push('/experience/$experienceId');
  }

  void _toggleFavorite(String experienceId) {
    // Handle favorite toggle
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to favorites'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Top bar widget with logo and action icons
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
              onPressed: () {},
              color: AppColors.textPrimary,
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
