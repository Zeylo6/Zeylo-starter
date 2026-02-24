import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/loading_shimmer.dart';

/// Full-screen image gallery for experience images
///
/// Features:
/// - PageView for swiping between images
/// - Page indicators at the bottom
/// - Back button to close
/// - Tap to hide/show UI elements
class ExperienceGalleryScreen extends StatefulWidget {
  /// List of image URLs
  final List<String> images;

  /// Initial page index
  final int initialPage;

  const ExperienceGalleryScreen({
    required this.images,
    this.initialPage = 0,
    Key? key,
  }) : super(key: key);

  @override
  State<ExperienceGalleryScreen> createState() =>
      _ExperienceGalleryScreenState();
}

class _ExperienceGalleryScreenState extends State<ExperienceGalleryScreen> {
  late PageController _pageController;
  late int _currentPage;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Image carousel
            PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: widget.images[index],
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      const Center(child: ShimmerListTile()),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(Icons.image_not_supported),
                    ),
                  ),
                );
              },
            ),

            // Back button
            if (_showControls)
              Positioned(
                top: MediaQuery.of(context).padding.top + AppSpacing.lg,
                left: AppSpacing.lg,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textInverse,
                      size: 20,
                    ),
                  ),
                ),
              ),

            // Image count
            if (_showControls)
              Positioned(
                top: MediaQuery.of(context).padding.top + AppSpacing.lg,
                right: AppSpacing.lg,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Text(
                    '${_currentPage + 1}/${widget.images.length}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textInverse,
                    ),
                  ),
                ),
              ),

            // Page indicators
            if (_showControls && widget.images.length > 1)
              Positioned(
                bottom: AppSpacing.lg + MediaQuery.of(context).padding.bottom,
                left: 0,
                right: 0,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.images.length,
                      (index) => Container(
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
