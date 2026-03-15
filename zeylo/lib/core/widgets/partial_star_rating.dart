import 'package:flutter/material.dart';

/// A widget that displays a 5-star rating with partial filling support.
class PartialStarRating extends StatelessWidget {
  /// The rating to display (0.0 to 5.0)
  final double rating;

  /// The size of each star
  final double size;

  /// Color for filled stars
  final Color color;

  /// Color for empty/unfilled stars
  final Color? backgroundColor;

  const PartialStarRating({
    required this.rating,
    this.size = 18,
    this.color = const Color(0xFFFFB800), // Standard gold star color
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return _buildStar(index);
      }),
    );
  }

  Widget _buildStar(int index) {
    // Determine the fill level for this specific star
    // index 0 -> rating between 0 and 1
    // index 1 -> rating between 1 and 2, etc.
    double fillPercent = 0.0;
    if (rating >= index + 1) {
      fillPercent = 1.0;
    } else if (rating > index) {
      fillPercent = rating - index;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background star (unfilled)
          Icon(
            Icons.star_rounded,
            size: size,
            color: backgroundColor ?? Colors.grey.withOpacity(0.3),
          ),
          // Foreground star (filled part)
          if (fillPercent > 0)
            ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: fillPercent,
                child: Icon(
                  Icons.star_rounded,
                  size: size,
                  color: color,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
