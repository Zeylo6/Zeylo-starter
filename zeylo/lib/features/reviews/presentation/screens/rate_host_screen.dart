import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/rating_widget.dart';
import '../providers/review_provider.dart';

/// Rate host screen for submitting experience reviews
/// Based on Figma design "iPhone 16 Pro Max - 16"
class RateHostScreen extends ConsumerStatefulWidget {
  /// Host profile photo URL
  final String hostPhotoUrl;

  /// Host name to display
  final String hostName;

  /// Experience title
  final String experienceTitle;

  /// Experience ID for the review
  final String experienceId;

  /// User ID of the reviewer
  final String userId;

  /// User name of the reviewer
  final String userName;

  /// Callback when review is submitted
  final Function(double rating, String comment)? onReviewSubmitted;

  const RateHostScreen({
    required this.hostPhotoUrl,
    required this.hostName,
    required this.experienceTitle,
    required this.experienceId,
    required this.userId,
    required this.userName,
    this.onReviewSubmitted,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<RateHostScreen> createState() => _RateHostScreenState();
}

class _RateHostScreenState extends ConsumerState<RateHostScreen> {
  late TextEditingController _commentController;
  String? _commentError;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() {
    final formState = ref.read(reviewFormProvider);

    if (formState.rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    final notifier = ref.read(reviewFormProvider.notifier);
    notifier.setLoading(true);

    // Simulate submission
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        notifier.setLoading(false);
        widget.onReviewSubmitted?.call(formState.rating, formState.comment);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your review!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(reviewFormProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.xl),

            // Host Profile Photo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
                image: widget.hostPhotoUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(widget.hostPhotoUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.hostPhotoUrl.isEmpty
                  ? Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(widget.hostName),
                          style: AppTypography.headlineLarge.copyWith(
                            color: AppColors.textInverse,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Rating Title
            Text(
              'Rate ${widget.hostName}',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Experience Subtitle
            Text(
              'How was your ${widget.experienceTitle}?',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Star Rating
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.xl,
                horizontal: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  RatingWidget(
                    rating: formState.rating,
                    isInteractive: true,
                    starSize: 56,
                    spacing: AppSpacing.md,
                    showRatingText: false,
                    onRatingChanged: (rating) {
                      ref.read(reviewFormProvider.notifier).updateRating(rating);
                    },
                  ),
                  if (formState.rating > 0) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _getRatingText(formState.rating),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Comment Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leave a comment',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildCommentField(),
                if (_commentError != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _commentError!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ZeyloButton(
                    onPressed: () => Navigator.pop(context),
                    label: 'Skip',
                    variant: ButtonVariant.outlined,
                    height: 48,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ZeyloButton(
                    onPressed: _submitReview,
                    label: 'Submit',
                    variant: ButtonVariant.filled,
                    isLoading: formState.isLoading,
                    height: 48,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: _commentError != null ? AppColors.error : AppColors.border,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: TextField(
        controller: _commentController,
        maxLines: 4,
        minLines: 4,
        onChanged: (value) {
          ref.read(reviewFormProvider.notifier).updateComment(value);
          if (_commentError != null) {
            setState(() {
              _commentError = null;
            });
          }
        },
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Share your experience...',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppSpacing.lg),
        ),
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating <= 2) {
      return 'We\'re sorry to hear that. How can we improve?';
    } else if (rating <= 3) {
      return 'Thanks for the feedback!';
    } else if (rating <= 4) {
      return 'Glad you enjoyed it!';
    } else {
      return 'Amazing! We\'re thrilled you loved it!';
    }
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'H';
  }
}
