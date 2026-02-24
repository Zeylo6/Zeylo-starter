import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// ShimmerExperienceCard - Shimmer loading skeleton for experience cards
class ShimmerExperienceCard extends StatelessWidget {
  /// Card height
  final double height;

  const ShimmerExperienceCard({
    this.height = 320,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.background,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Expanded(
              flex: 2,
              child: Container(
                color: AppColors.surface,
              ),
            ),
            // Content area
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Host info line
                    Container(
                      height: 16,
                      width: 150,
                      color: AppColors.surface,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Location line
                    Container(
                      height: 12,
                      width: 100,
                      color: AppColors.surface,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Price line
                    Container(
                      height: 14,
                      width: 80,
                      color: AppColors.surface,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Description lines
                    Container(
                      height: 12,
                      width: double.infinity,
                      color: AppColors.surface,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ShimmerProfileHeader - Shimmer loading skeleton for profile header
class ShimmerProfileHeader extends StatelessWidget {
  /// Header height
  final double height;

  const ShimmerProfileHeader({
    this.height = 200,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.background,
      child: Container(
        height: height,
        color: AppColors.surface,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Name placeholder
            Container(
              height: 18,
              width: 150,
              color: AppColors.surface,
            ),
            const SizedBox(height: AppSpacing.md),
            // Email placeholder
            Container(
              height: 14,
              width: 180,
              color: AppColors.surface,
            ),
            const SizedBox(height: AppSpacing.lg),
            // Stats row
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 16,
                        width: 40,
                        color: AppColors.surface,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        height: 12,
                        width: 50,
                        color: AppColors.surface,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 16,
                        width: 40,
                        color: AppColors.surface,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        height: 12,
                        width: 50,
                        color: AppColors.surface,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ShimmerListTile - Shimmer loading skeleton for generic list items
class ShimmerListTile extends StatelessWidget {
  /// Tile height
  final double height;

  /// Whether to show avatar
  final bool showAvatar;

  const ShimmerListTile({
    this.height = 72,
    this.showAvatar = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.background,
      child: Container(
        height: height,
        padding: const EdgeInsets.all(AppSpacing.md),
        color: AppColors.background,
        child: Row(
          children: [
            if (showAvatar) ...[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 14,
                    width: 150,
                    color: AppColors.surface,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    height: 12,
                    width: 100,
                    color: AppColors.surface,
                  ),
                ],
              ),
            ),
            Container(
              height: 16,
              width: 60,
              color: AppColors.surface,
            ),
          ],
        ),
      ),
    );
  }
}

/// ShimmerText - Shimmer loading skeleton for text lines
class ShimmerText extends StatelessWidget {
  /// Line width. Defaults to full width
  final double? width;

  /// Line height. Defaults to 14
  final double height;

  /// Number of lines
  final int lineCount;

  /// Space between lines
  final double spacing;

  const ShimmerText({
    this.width,
    this.height = 14,
    this.lineCount = 3,
    this.spacing = AppSpacing.md,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          lineCount,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: index < lineCount - 1 ? spacing : 0,
            ),
            child: Container(
              height: height,
              width: index == lineCount - 1 ? width ?? 100 : width ?? double.infinity,
              color: AppColors.surface,
            ),
          ),
        ),
      ),
    );
  }
}

/// ShimmerGrid - Shimmer loading skeleton for grid items
class ShimmerGrid extends StatelessWidget {
  /// Number of columns
  final int crossAxisCount;

  /// Number of items
  final int itemCount;

  /// Cross axis spacing
  final double crossAxisSpacing;

  /// Main axis spacing
  final double mainAxisSpacing;

  /// Item height
  final double itemHeight;

  const ShimmerGrid({
    this.crossAxisCount = 2,
    this.itemCount = 4,
    this.crossAxisSpacing = AppSpacing.md,
    this.mainAxisSpacing = AppSpacing.md,
    this.itemHeight = 250,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.background,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: 1,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          );
        },
      ),
    );
  }
}
