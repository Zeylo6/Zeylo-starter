import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Single onboarding page widget
///
/// Displays a page with image, title, and subtitle
class OnboardingPage extends StatelessWidget {
  /// The image asset path to display
  final String imagePath;

  /// The page title
  final String title;

  /// The page subtitle
  final String subtitle;

  /// Creates a new OnboardingPage
  const OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    Key? key,
  }) : super(key: key);

  IconData _getIconForPage() {
    if (imagePath.contains('1')) return Icons.explore_outlined;
    if (imagePath.contains('2')) return Icons.search_outlined;
    return Icons.people_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Image with fallback for missing assets
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            height: 400,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 400,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryLight.withOpacity(0.3),
                      AppColors.primary.withOpacity(0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getIconForPage(),
                    size: 120,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Text(
                  title,
                  style: AppTypography.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                // Subtitle
                Text(
                  subtitle,
                  style: AppTypography.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
