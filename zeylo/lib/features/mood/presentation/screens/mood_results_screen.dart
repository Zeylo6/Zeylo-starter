import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/mood_provider.dart';
import '../widgets/match_badge.dart';

/// Mood results screen
///
/// Based on Figma "iPhone 16 Pro Max - 19"
/// Displays experiences matching the user's mood with:
/// - Current mood display with edit option
/// - Filterable tabs (All, Events, People, Business)
/// - Top experiences with match percentage badges
/// - Book buttons for each experience
class MoodResultsScreen extends ConsumerStatefulWidget {
  const MoodResultsScreen({super.key});

  @override
  ConsumerState<MoodResultsScreen> createState() =>
      _MoodResultsScreenState();
}

class _MoodResultsScreenState extends ConsumerState<MoodResultsScreen> {
  int _selectedFilterIndex = 0;

  final List<String> _filterTabs = ['All', 'Events', 'People', 'Businesses'];

  // Mock data for demonstration
  final List<MoodExperienceResult> _mockResults = [
    MoodExperienceResult(
      id: '1',
      title: 'Surfing Lessons',
      category: 'Events',
      location: 'Mirissa',
      description: 'Learn to surf with experienced instructors',
      matchPercentage: 98,
      imageUrl: 'https://via.placeholder.com/300x200?text=Surfing',
      price: '25-50',
      type: MoodResultType.event,
    ),
    MoodExperienceResult(
      id: '2',
      title: 'Alex is looking for a hiking buddy',
      category: 'People',
      location: 'Kandy',
      description: 'Join a friendly morning hike with a local group',
      matchPercentage: 95,
      imageUrl: 'https://via.placeholder.com/300x200?text=People',
      price: 'Free',
      type: MoodResultType.people,
    ),
    MoodExperienceResult(
      id: '3',
      title: 'Luna Coffee Roasters',
      category: 'Businesses',
      location: 'Colombo',
      description: 'Relaxing coffee tasting and live acoustic evening',
      matchPercentage: 92,
      imageUrl: 'https://via.placeholder.com/300x200?text=Business',
      price: '10-20',
      type: MoodResultType.business,
    ),
  ];

  List<MoodExperienceResult> get _filteredResults {
    switch (_selectedFilterIndex) {
      case 1:
        return _mockResults
            .where((result) => result.type == MoodResultType.event)
            .toList();
      case 2:
        return _mockResults
            .where((result) => result.type == MoodResultType.people)
            .toList();
      case 3:
        return _mockResults
            .where((result) => result.type == MoodResultType.business)
            .toList();
      default:
        return List<MoodExperienceResult>.from(_mockResults);
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodState = ref.watch(moodProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current mood section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Matching mood',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        moodState.selectedMood ?? 'Your mood',
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Edit',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Filter tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    _filterTabs.length,
                    (index) {
                      final isSelected = _selectedFilterIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedFilterIndex = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              border: isSelected
                                  ? null
                                  : Border(
                                      bottom: BorderSide(
                                        color: AppColors.border,
                                        width: 2,
                                      ),
                                    ),
                              borderRadius: isSelected
                                  ? BorderRadius.circular(AppRadius.full)
                                  : null,
                            ),
                            child: Text(
                              _filterTabs[index],
                              style: AppTypography.labelMedium.copyWith(
                                color: isSelected
                                    ? AppColors.textInverse
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Top Experiences header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Experiences',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to see all results
                    },
                    child: Text(
                      'See all',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Experience cards
              if (_filteredResults.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Center(
                    child: Text(
                      'No results for this filter',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: _filteredResults.map((result) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: _buildExperienceCard(result),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExperienceCard(MoodExperienceResult result) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with match badge
          Stack(
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  topRight: Radius.circular(AppRadius.lg),
                ),
                child: CachedNetworkImage(
                  imageUrl: result.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      _buildImagePlaceholder(),
                  errorWidget: (context, url, error) =>
                      _buildImagePlaceholder(),
                ),
              ),
              // Match badge
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: MatchBadgeWidget(
                  matchPercentage: result.matchPercentage,
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  result.title,
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Category and location
                Text(
                  '${result.category} • ${result.location}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Description
                Text(
                  result.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Book button and price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ZeyloButton(
                        label: 'Book',
                        height: 44,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Book ${result.title}'),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      '\$${result.price}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: AppColors.surface,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.textHint,
          size: 40,
        ),
      ),
    );
  }
}

/// Mock experience result for mood matching
class MoodExperienceResult {
  final String id;
  final String title;
  final String category;
  final String location;
  final String description;
  final int matchPercentage;
  final String imageUrl;
  final String price;
  final MoodResultType type;

  MoodExperienceResult({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.description,
    required this.matchPercentage,
    required this.imageUrl,
    required this.price,
    required this.type,
  });
}

enum MoodResultType {
  event,
  people,
  business,
}
