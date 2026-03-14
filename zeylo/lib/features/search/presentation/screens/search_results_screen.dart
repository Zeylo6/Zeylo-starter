import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/experience_card.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/discovery/discovery_utils.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../widgets/filter_sheet.dart';

/// Search results screen
///
/// Features:
/// - Search query display
/// - Filter button (bottom sheet)
/// - Results list with filtering
/// - Sort options
class SearchResultsScreen extends ConsumerStatefulWidget {
  /// Search query
  final String query;

  const SearchResultsScreen({
    required this.query,
    super.key,
  });

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'Search Results',
          style: AppTypography.headlineSmall,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Search bar and filter controls
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search input
                  Material(
                    color: Colors.transparent,
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: AppTypography.bodyMediumSecondary,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            Navigator.of(context).pop();
                          },
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Controls row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sort dropdown
                      Expanded(
                        child: _buildSortDropdown(
                          ref.watch(discoverySortModeProvider),
                        ),
                      ),

                      // Filter button
                      _buildFilterButton(context),
                      const SizedBox(width: AppSpacing.sm),

                      ElevatedButton(
                        onPressed: () => _showTripPlanner(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 6,
                          ),
                        ),
                        child: Text(
                          'Plan Trip',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textInverse,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Results
          _buildResultsList(),
        ],
      ),
    );
  }

  Widget _buildSortDropdown(DiscoverySortMode sortMode) {
    return DropdownButton<String>(
      value: _sortModeValue(sortMode),
      underline: const SizedBox.shrink(),
      isExpanded: true,
      items: const [
        DropdownMenuItem(
          value: 'relevance',
          child: Text('Most Relevant'),
        ),
        DropdownMenuItem(
          value: 'price_asc',
          child: Text('Price: Low to High'),
        ),
        DropdownMenuItem(
          value: 'price_desc',
          child: Text('Price: High to Low'),
        ),
        DropdownMenuItem(
          value: 'rating',
          child: Text('Top Rated'),
        ),
        DropdownMenuItem(
          value: 'newest',
          child: Text('Newest'),
        ),
        DropdownMenuItem(
          value: 'smart',
          child: Text('Smart Match'),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          final nextMode = _sortModeFromValue(value);
          ref.read(discoverySortModeProvider.notifier).state = nextMode;
        }
      },
    );
  }

  String _sortModeValue(DiscoverySortMode sortMode) {
    if (sortMode == DiscoverySortMode.priceLow) return 'price_asc';
    if (sortMode == DiscoverySortMode.priceHigh) return 'price_desc';
    if (sortMode == DiscoverySortMode.rating) return 'rating';
    if (sortMode == DiscoverySortMode.newest) return 'newest';
    if (sortMode == DiscoverySortMode.smart) return 'smart';
    return 'relevance';
  }

  DiscoverySortMode _sortModeFromValue(String value) {
    switch (value) {
      case 'price_asc':
        return DiscoverySortMode.priceLow;
      case 'price_desc':
        return DiscoverySortMode.priceHigh;
      case 'rating':
        return DiscoverySortMode.rating;
      case 'newest':
        return DiscoverySortMode.newest;
      case 'smart':
        return DiscoverySortMode.smart;
      case 'relevance':
      default:
        return DiscoverySortMode.relevance;
    }
  }

  Widget _buildFilterButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => const FilterSheet(),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.tune, size: 18),
              const SizedBox(width: 4),
              Text(
                'Filters',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return ref.watch(experiencesByFilterProvider).when(
          data: (allExperiences) {
            final results = allExperiences
                .where((exp) =>
                    exp.title.toLowerCase().contains(widget.query.toLowerCase()) ||
                    exp.description
                        .toLowerCase()
                        .contains(widget.query.toLowerCase()) ||
                    exp.category.toLowerCase().contains(widget.query.toLowerCase()))
                .toList();

            if (results.isEmpty) {
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
                          'No results found',
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
                    final experience = results[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: ExperienceCard(
                        heroTag: 'search_experience_${experience.id}',
                        imageUrl: experience.coverImage,
                        hostName: experience.hostName,
                        hostAvatarUrl: experience.hostPhotoUrl,
                        isHostVerified: experience.isHostVerified,
                        location:
                            '${experience.location.city}, ${experience.location.country}',
                        price:
                            'LKR ${experience.price.toStringAsFixed(0)}',
                        description: experience.shortDescription,
                        rating: experience.averageRating,
                        ratingCount: experience.reviewCount,
                        onTap: () => _navigateToDetail(experience.id),
                      ),
                    );
                  },
                  childCount: results.length,
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

  void _navigateToDetail(String experienceId) {
    Navigator.of(context).pushNamed(
      '/experience-detail',
      arguments: experienceId,
    );
  }

  void _showTripPlanner() {
    final results = ref.read(experiencesByFilterProvider).value ?? [];
    final trip = DiscoveryUtils.buildTripPlan(
      experiences: results,
      query: widget.query,
      maxStops: 4,
      maxTotalMinutes: 300,
    );

    if (trip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No feasible trip plan from these results.'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Suggested Trip', style: AppTypography.headlineSmall),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Optimized route based on proximity and duration.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ...trip.map(
                      (leg) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (leg.travelMinutesFromPrevious > 0)
                              Text(
                                'Travel ${leg.distanceFromPreviousKm.toStringAsFixed(1)} km '
                                '(${leg.travelMinutesFromPrevious} min walk) then ${leg.experience.duration} min',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            if (leg.travelMinutesFromPrevious > 0)
                              const SizedBox(height: AppSpacing.sm),
                            ExperienceCard(
                              imageUrl: leg.experience.coverImage,
                              hostName: leg.experience.hostName,
                              hostAvatarUrl: leg.experience.hostPhotoUrl,
                              isHostVerified: leg.experience.isHostVerified,
                              location:
                                  '${leg.experience.location.city}, ${leg.experience.location.country}',
                              price:
                                  'LKR ${leg.experience.price.toStringAsFixed(0)}',
                              description: leg.experience.shortDescription,
                              rating: leg.experience.averageRating,
                              ratingCount: leg.experience.reviewCount,
                              onTap: () {
                                Navigator.of(context).pop();
                                _navigateToDetail(leg.experience.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
