import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// RatingWidget for displaying and rating
///
/// Features:
/// - Star display (1-5 stars, purple for filled/outlined)
/// - Interactive mode (for rating screen) vs display-only
/// - Shows rating number and count text (e.g., "4.9 (234)")
/// - Star size parameter
/// - Uses purple color for filled stars
///
/// Example:
/// ```dart
/// // Display only
/// RatingWidget(
///   rating: 4.8,
///   ratingCount: 234,
///   isInteractive: false,
/// )
///
/// // Interactive
/// RatingWidget(
///   rating: 0,
///   isInteractive: true,
///   onRatingChanged: (rating) => print('Rated: $rating'),
/// )
/// ```
class RatingWidget extends StatefulWidget {
  /// Current rating value (0-5)
  final double rating;

  /// Number of ratings (for display)
  final int? ratingCount;

  /// Whether the rating is interactive
  final bool isInteractive;

  /// Size of the stars
  final double starSize;

  /// Spacing between stars
  final double spacing;

  /// Callback when rating changes (interactive mode only)
  final ValueChanged<double>? onRatingChanged;

  /// Whether to show the rating text
  final bool showRatingText;

  /// Axis direction for stars
  final Axis axis;

  const RatingWidget({
    required this.rating,
    this.ratingCount,
    this.isInteractive = false,
    this.starSize = 20,
    this.spacing = AppSpacing.xs,
    this.onRatingChanged,
    this.showRatingText = true,
    this.axis = Axis.horizontal,
    Key? key,
  }) : super(key: key);

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
  }

  @override
  void didUpdateWidget(RatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rating != widget.rating && !widget.isInteractive) {
      _currentRating = widget.rating;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStars(),
            if (widget.showRatingText) ...[
              const SizedBox(width: AppSpacing.sm),
              _buildRatingText(),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStars() {
    return Flex(
      direction: widget.axis,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) {
          final ratingValue = index + 1.0;
          return GestureDetector(
            onTap: widget.isInteractive
                ? () {
                    setState(() {
                      _currentRating = ratingValue;
                    });
                    widget.onRatingChanged?.call(ratingValue);
                  }
                : null,
            child: Padding(
              padding: EdgeInsets.only(
                right: index < 4 ? widget.spacing : 0,
              ),
              child: _buildStar(ratingValue),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStar(double ratingValue) {
    final isFilled = _currentRating >= ratingValue;
    final isHalf = _currentRating > (ratingValue - 1) && !isFilled;

    if (isHalf) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.star_outline,
            size: widget.starSize,
            color: AppColors.primary,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: ClipRect(
              child: SizedBox(
                width: widget.starSize / 2,
                child: Icon(
                  Icons.star,
                  size: widget.starSize,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Icon(
      isFilled ? Icons.star : Icons.star_outline,
      size: widget.starSize,
      color: AppColors.primary,
    );
  }

  Widget _buildRatingText() {
    if (widget.ratingCount != null) {
      return Text(
        '${_currentRating.toStringAsFixed(1)} (${widget.ratingCount})',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Text(
      _currentRating.toStringAsFixed(1),
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
