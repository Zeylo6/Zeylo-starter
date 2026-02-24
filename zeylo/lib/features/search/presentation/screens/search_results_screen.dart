import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/experience_card.dart';
import '../../../../core/widgets/loading_shimmer.dart';
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
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  late TextEditingController _searchController;
  String _sortBy = 'relevance'; // relevance, price_asc, price_desc, rating

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
                      _buildSortDropdown(),

                      // Filter button
                      _buildFilterButton(context),
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

  Widget _buildSortDropdown() {
    return DropdownButton<String>(
      value: _sortBy,
      underline: const SizedBox.shrink(),
      items: [
        const DropdownMenuItem(
          value: 'relevance',
          child: Text('Most Relevant'),
        ),
        const DropdownMenuItem(
          value: 'price_asc',
          child: Text('Price: Low to High'),
        ),
        const DropdownMenuItem(
          value: 'price_desc',
          child: Text('Price: High to Low'),
        ),
        const DropdownMenuItem(
          value: 'rating',
          child: Text('Top Rated'),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _sortBy = value;
          });
        }
      },
    );
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
            // Filter based on search query
            var results = allExperiences
                .where((exp) =>
                    exp.title.toLowerCase().contains(widget.query.toLowerCase()) ||
                    exp.description.toLowerCase().contains(widget.query.toLowerCase()) ||
                    exp.category.toLowerCase().contains(widget.query.toLowerCase()))
                .toList();

            // Apply sorting
            switch (_sortBy) {
              case 'price_asc':
                results.sort((a, b) => a.price.compareTo(b.price));
                break;
              case 'price_desc':
                results.sort((a, b) => b.price.compareTo(a.price));
                break;
              case 'rating':
                results.sort((a, b) =>
                    b.averageRating.compareTo(a.averageRating));
                break;
              case 'relevance':
              default:
                // Default ordering
                break;
            }

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
}
