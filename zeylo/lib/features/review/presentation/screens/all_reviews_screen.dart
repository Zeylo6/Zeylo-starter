import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/partial_star_rating.dart';
import '../providers/review_provider.dart';
import '../../domain/entities/review_entity.dart';
import '../../../home/domain/entities/experience_entity.dart';

class AllReviewsScreen extends ConsumerStatefulWidget {
  final Experience experience;

  const AllReviewsScreen({
    required this.experience,
    super.key,
  });

  @override
  ConsumerState<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends ConsumerState<AllReviewsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Search suggestions
  final List<String> _suggestions = [
    'Amazing', 'Service', 'Value', 'Food', 'Atmosphere', 'Guide'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(experienceReviewsProvider(widget.experience.id));
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leadingWidth: 70,
        leading: Center(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              margin: const EdgeInsets.only(left: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.textInverse.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ),
        title: Text(
          'Experience reviews',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: reviewsAsync.when(
        data: (reviews) {
          final filteredReviews = reviews.where((r) {
            if (_searchQuery.isEmpty) return true;
            return r.message?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
          }).toList();

          return CustomScrollView(
            slivers: [
              // Rating Breakdown Header
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryHeader(reviews),
                      const SizedBox(height: AppSpacing.lg),
                      _buildRatingDistribution(reviews),
                      const SizedBox(height: AppSpacing.xl),
                      _buildSearchBar(),
                      const SizedBox(height: AppSpacing.md),
                      _buildSuggestions(),
                    ],
                  ),
                ),
              ),
              // Suggestions Section
              if (_suggestions.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: const SizedBox(height: AppSpacing.md),
                  ),
                ),
              // Review List
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: filteredReviews.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'No reviews found matching your search.',
                            style: AppTypography.bodyMediumSecondary,
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final review = filteredReviews[index];
                            return _buildReviewCard(context, ref, review, currentUser);
                          },
                          childCount: filteredReviews.length,
                        ),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSummaryHeader(List<ReviewEntity> reviews) {
    return Row(
      children: [
        // Green badge like in the reference image
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            widget.experience.averageRating.toStringAsFixed(1),
            style: AppTypography.headlineLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PartialStarRating(
              rating: widget.experience.averageRating,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              '(${widget.experience.reviewCount} reviews)',
              style: AppTypography.bodyMediumSecondary.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingDistribution(List<ReviewEntity> reviews) {
    if (reviews.isEmpty) return const SizedBox.shrink();

    final total = reviews.length;
    final counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var r in reviews) {
      final rInt = r.rating.floor();
      if (counts.containsKey(rInt)) {
        counts[rInt] = (counts[rInt] ?? 0) + 1;
      }
    }

    return Column(
      children: [
        _buildDistributionRow('Excellent', counts[5]!, total),
        _buildDistributionRow('Very good', counts[4]!, total),
        _buildDistributionRow('Average', counts[3]!, total),
        _buildDistributionRow('Poor', counts[2]!, total),
        _buildDistributionRow('Terrible', counts[1]!, total),
      ],
    );
  }

  Widget _buildDistributionRow(String label, int count, int total) {
    final percent = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 12,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 20,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Search reviews...',
          hintStyle: AppTypography.bodyMediumSecondary,
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, WidgetRef ref, ReviewEntity review, User? currentUser) {
    final isHelpful = currentUser != null && review.helpfulUserIds.contains(currentUser.uid);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Seeker',
                style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    review.rating.toStringAsFixed(1),
                    style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          if (review.message != null && review.message!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              review.message!,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (currentUser == null) return;
                      await ref.read(reviewRepositoryProvider).toggleHelpful(review.id, currentUser.uid);
                      // Provider updates automatically due to streaming implementaton in previous step
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isHelpful ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isHelpful ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                            size: 14,
                            color: isHelpful ? AppColors.primary : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Helpful${review.helpfulUserIds.isNotEmpty ? ' (${review.helpfulUserIds.length})' : ''}',
                            style: AppTypography.labelSmall.copyWith(
                              color: isHelpful ? AppColors.primary : AppColors.textSecondary,
                              fontWeight: isHelpful ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  GestureDetector(
                    onTap: () async {
                      if (currentUser == null) return;
                      // Logic for report confirmation...
                    },
                    child: Icon(Icons.flag_outlined, color: AppColors.textSecondary, size: 16),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildSuggestions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _suggestions.map((suggestion) {
        final isSelected = _searchQuery.toLowerCase() == suggestion.toLowerCase();
        return GestureDetector(
          onTap: () {
            setState(() {
              _searchQuery = isSelected ? '' : suggestion;
              _searchController.text = _searchQuery;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.1),
              ),
            ),
            child: Text(
              suggestion,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
