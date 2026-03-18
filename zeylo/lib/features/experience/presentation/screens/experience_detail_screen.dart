import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../messaging/presentation/providers/messaging_provider.dart';
import '../widgets/experience_info_section.dart';
import '../widgets/host_info_card.dart';
import '../../../../core/widgets/partial_star_rating.dart';
import 'package:zeylo/features/review/presentation/providers/review_provider.dart';
import '../../../home/domain/entities/experience_entity.dart';
import 'package:zeylo/features/review/presentation/screens/all_reviews_screen.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';

/// Experience detail screen
///
/// Refactored for Web responsive layout:
/// - Desktop (≥800px): Hero image banner, Two-column layout (content left, sticky booking card right)
/// - Mobile: Original scroll view with sticky bottom AppBar for booking
class ExperienceDetailScreen extends ConsumerStatefulWidget {
  final String experienceId;

  const ExperienceDetailScreen({
    required this.experienceId,
    super.key,
  });

  @override
  ConsumerState<ExperienceDetailScreen> createState() =>
      _ExperienceDetailScreenState();
}

class _ExperienceDetailScreenState
    extends ConsumerState<ExperienceDetailScreen> {

  @override
  Widget build(BuildContext context) {
    final isFavorited = ref.watch(isFavoritedProvider(widget.experienceId));
    
    return ref.watch(experienceDetailProvider(widget.experienceId)).when(
          data: (experience) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 800;
                    if (isDesktop) {
                      return _buildDesktopLayout(context, experience, isFavorited);
                    }
                    return _buildMobileLayout(context, experience, isFavorited);
                  },
                ),
              ),
              bottomNavigationBar: MediaQuery.of(context).size.width < 800
                  ? _buildBookNowButton(context, experience)
                  : null, // Desktop uses sticky card
            );
          },
          loading: () => Scaffold(
            backgroundColor: AppColors.background,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ShimmerListTile(height: 250),
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Column(
                      children: List.generate(
                        4,
                        (index) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.lg,
                          ),
                          child: ShimmerListTile(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          error: (error, stackTrace) => Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Experience'),
              elevation: 0,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Failed to load experience',
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
        );
  }

  // ─────────────────────────── DESKTOP LAYOUT ───────────────────────────

  Widget _buildDesktopLayout(BuildContext context, Experience experience, bool isFavorited) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildDesktopHeader(experience, isFavorited),
        ),
        SliverToBoxAdapter(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 1200, // Max width for content
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl, vertical: AppSpacing.xxxl),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Details
                  Expanded(
                    flex: 7,
                    child: _buildMainContent(experience),
                  ),
                  const SizedBox(width: AppSpacing.xxxl * 1.5),
                  // Right Column: Sticky Booking Card
                  SizedBox(
                    width: 380,
                    child: _buildStickyBookingCard(experience),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader(Experience experience, bool isFavorited) {
    return Stack(
      children: [
        // Hero Image
        SizedBox(
          width: double.infinity,
          height: 480,
          child: CachedNetworkImage(
            imageUrl: experience.coverImage,
            fit: BoxFit.cover,
            placeholder: (context, url) => ShimmerListTile(height: 480),
            errorWidget: (context, url, error) => Container(
              color: AppColors.surface,
              child: const Icon(Icons.image_not_supported),
            ),
          ),
        ),
        // Overlay gradient for readability
        Container(
          height: 480,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.5),
                Colors.transparent,
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Top Bar
        Positioned(
          top: AppSpacing.xxl,
          left: AppSpacing.xxxl,
          right: AppSpacing.xxxl,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textPrimary),
                      const SizedBox(width: 8),
                      Text('Back', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              // Favorite Button
              GestureDetector(
                onTap: _toggleFavorite,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? AppColors.error : AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStickyBookingCard(Experience experience) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rs. ${experience.price.toStringAsFixed(0)}',
            style: AppTypography.displayMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildLocation(experience.location.address, experience.location.city),
          const SizedBox(height: AppSpacing.xxl),
          
          // Options / Selectors (Placeholder for future)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700)),
                    Text('Add dates', style: AppTypography.bodySmallSecondary),
                  ],
                ),
                const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _bookNow(experience),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                elevation: 0,
              ),
              child: Text(
                'Book Now',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              'You won\'t be charged yet',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── MOBILE LAYOUT ───────────────────────────

  Widget _buildMobileLayout(BuildContext context, Experience experience, bool isFavorited) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCoverImage(experience.coverImage),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _buildMainContent(experience),
              ),
            ],
          ),
        ),
        // Back button
        Positioned(
          top: AppSpacing.md,
          left: AppSpacing.lg,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.textInverse.withOpacity(0.9),
                shape: BoxShape.circle,
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
        // Favorite button
        Positioned(
          top: AppSpacing.md,
          right: AppSpacing.lg,
          child: GestureDetector(
            onTap: _toggleFavorite,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.textInverse.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited ? AppColors.error : AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────── SHARED CONTENT ───────────────────────────

  Widget _buildMainContent(Experience experience) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          experience.title,
          style: AppTypography.displayMedium,
        ),
        const SizedBox(height: AppSpacing.md),

        // Host and price row (Price only visible on mobile, as Desktop has sticky card)
        LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = MediaQuery.of(context).size.width >= 800;
            return _buildHostPriceRow(
              experience.hostName,
              experience.hostPhotoUrl,
              experience.price,
              experience.currency,
              hidePrice: isDesktop,
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),

        // Location
        _buildLocation(
          experience.location.address,
          experience.location.city,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Description
        Text(
          experience.description,
          style: AppTypography.bodyLarge.copyWith(height: 1.8),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const Divider(color: AppColors.border),
        const SizedBox(height: AppSpacing.xxl),

        // What's included section
        ExperienceInfoSection(
          title: "What's Included",
          items: experience.includes,
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Requirements section
        if (experience.requirements.isNotEmpty) ...[
          ExperienceInfoSection(
            title: 'Requirements',
            items: experience.requirements,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],

        const Divider(color: AppColors.border),
        const SizedBox(height: AppSpacing.xxl),

        // Host bio card
        HostInfoCard(
          hostName: experience.hostName,
          hostPhotoUrl: experience.hostPhotoUrl,
          rating: experience.averageRating,
          reviewCount: experience.reviewCount,
          bio:
              'Experienced host with ${experience.reviewCount} reviews. Specializes in ${experience.category} experiences.',
          onMessageTap: () => _openChatWithHost(context, experience),
        ),
        const SizedBox(height: AppSpacing.xxxl),

        // Reviews Section
        _buildReviewsSection(context, experience),
        const SizedBox(height: 100), // padding for bottom button
      ],
    );
  }

  // ─────────────────────────── HELPERS ───────────────────────────

  Future<void> _openChatWithHost(BuildContext context, Experience experience) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final conversation = await ref.read(
      getOrCreateConversationProvider((currentUser.uid, experience.hostId)).future,
    );
    if (mounted) {
      context.push('/chat/${conversation.id}', extra: {
        'otherUserName': experience.hostName,
        'currentUserId': currentUser.uid,
      });
    }
  }

  Widget _buildCoverImage(String imageUrl) {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => ShimmerListTile(height: 300),
        errorWidget: (context, url, error) => Container(
          color: AppColors.surface,
          child: const Icon(Icons.image_not_supported),
        ),
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context, Experience experience) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Consumer(
      builder: (context, ref, child) {
        final reviewsAsync = ref.watch(experienceReviewsProvider(experience.id));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Guest Reviews',
                  style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: AppSpacing.md),
                if (experience.reviewCount > 0) ...[
                  Text(
                    experience.averageRating.toStringAsFixed(1),
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PartialStarRating(
                    rating: experience.averageRating,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      '${experience.reviewCount}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (experience.reviewCount > 3)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllReviewsScreen(experience: experience),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'View All',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            reviewsAsync.when(
              data: (reviews) {
                if (reviews.isEmpty) {
                  return Text(
                    'No reviews yet for this experience.',
                    style: AppTypography.bodyMediumSecondary,
                  );
                }
                final topReviews = [...reviews];
                topReviews.sort((a, b) => b.rating.compareTo(a.rating));
                final reviewsToShow = topReviews.take(3).toList();

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 800;
                    
                    if (isDesktop) {
                       // Grid layout for reviews on desktop
                       return GridView.builder(
                         shrinkWrap: true,
                         physics: const NeverScrollableScrollPhysics(),
                         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                           crossAxisCount: 2,
                           crossAxisSpacing: AppSpacing.lg,
                           mainAxisSpacing: AppSpacing.lg,
                           childAspectRatio: 2.5,
                         ),
                         itemCount: reviewsToShow.length,
                         itemBuilder: (context, index) {
                           return _buildReviewTile(reviewsToShow[index], experience, currentUser, ref);
                         },
                       );
                    }
                    
                    return Column(
                      children: reviewsToShow.map((review) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _buildReviewTile(review, experience, currentUser, ref),
                        );
                      }).toList(),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReviewTile(dynamic review, Experience experience, User? currentUser, WidgetRef ref) {
    final isHelpful = currentUser != null && review.helpfulUserIds.contains(currentUser.uid);

    return Container(
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
                child: const Icon(Icons.person,
                    color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Seeker',
                style: AppTypography.labelMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFFFB800), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    review.rating.toStringAsFixed(1),
                    style: AppTypography.labelSmall
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          if (review.message != null && review.message!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: Text(
                review.message!,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textPrimary),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ] else ... [
             const Spacer(),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                style: AppTypography.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (currentUser == null) return;
                      await ref
                          .read(reviewRepositoryProvider)
                          .toggleHelpful(review.id, currentUser.uid);
                      ref.invalidate(
                          experienceReviewsProvider(experience.id));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isHelpful
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isHelpful
                                ? Icons.thumb_up_rounded
                                : Icons.thumb_up_outlined,
                            size: 14,
                            color: isHelpful
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Helpful${review.helpfulUserIds.isNotEmpty ? ' (${review.helpfulUserIds.length})' : ''}',
                            style: AppTypography.labelSmall.copyWith(
                              color: isHelpful
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: isHelpful
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
                      final confirm = await _showReportConfirmation(context);
                      if (confirm == true) {
                        await ref
                            .read(reviewRepositoryProvider)
                            .reportReview(review.id, currentUser.uid,
                                experience.hostId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Review reported to host.'),
                              backgroundColor: AppColors.textPrimary,
                            ),
                          );
                        }
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.flag_outlined,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Report',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool?> _showReportConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Review'),
        content: const Text(
            'Are you sure you want to report this review? This will notify the host to investigate.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Report', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildHostPriceRow(
    String hostName,
    String hostPhotoUrl,
    double price,
    String currency, {
    bool hidePrice = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: CachedNetworkImage(
                  imageUrl: hostPhotoUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: AppColors.surface),
                  errorWidget: (context, url, error) =>
                      Container(color: AppColors.surface),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              hostName,
              style: AppTypography.titleMedium,
            ),
          ],
        ),
        if (!hidePrice)
          Text(
            'Rs. ${price.toStringAsFixed(0)}',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildLocation(String address, String city) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            '$address, $city',
            style: AppTypography.bodyMediumSecondary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBookNowButton(BuildContext context, dynamic experience) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: AppSpacing.lg + MediaQuery.of(context).padding.bottom,
      ),
      color: AppColors.background,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: Material(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            onTap: () => _bookNow(experience),
            child: Center(
              child: Text(
                'Book Now',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textInverse,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleFavorite() {
    final isFavorited = ref.read(isFavoritedProvider(widget.experienceId));
    ref.read(favoritesProvider.notifier).toggleFavorite(widget.experienceId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFavorited ? 'Removed from favorites' : 'Added to favorites'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _bookNow(dynamic experience) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to book this experience.')),
      );
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance.collection('bookings').doc();

      await docRef.set({
        'id': docRef.id,
        'experienceId': experience.id,
        'experienceTitle': experience.title,
        'experienceCoverImage': experience.coverImage,
        'userId': user.uid,
        'hostId': experience.hostId,
        'date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))), 
        'startTime': '10:00 AM', 
        'guests': 1, 
        'totalPrice': experience.price,
        'status': 'pending',
        'paymentStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('activities').add({
        'userId': experience.hostId, 
        'title': 'New Booking Request',
        'message': 'You have a new booking request for ${experience.title}!',
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'new_booking',
        'isRead': false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking request sent to host!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
