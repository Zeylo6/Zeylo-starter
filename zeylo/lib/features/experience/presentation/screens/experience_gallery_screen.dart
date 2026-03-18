import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/loading_shimmer.dart';

/// Full-screen image gallery for experience images
///
/// Refactored for Web responsive layout:
/// - Desktop (≥800px): Added explicit left/right navigation chevrons, close button instead of back arrow.
/// - Mobile: Original swiping PageView with single back button.
class ExperienceGalleryScreen extends StatefulWidget {
  final List<String> images;
  final int initialPage;

  const ExperienceGalleryScreen({
    required this.images,
    this.initialPage = 0,
    super.key,
  });

  @override
  State<ExperienceGalleryScreen> createState() =>
      _ExperienceGalleryScreenState();
}

class _ExperienceGalleryScreenState extends State<ExperienceGalleryScreen> {
  late PageController _pageController;
  late int _currentPage;
  bool _showControls = true;
  bool _isHoveringLeft = false;
  bool _isHoveringRight = false;
  bool _isHoveringClose = false;

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

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_currentPage < widget.images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 800;
          return GestureDetector(
            onTap: _toggleControls,
            child: Stack(
              children: [
                // Image carousel
                PageView.builder(
                  controller: _pageController,
                  physics: isDesktop ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemCount: widget.images.length,
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: CachedNetworkImage(
                        imageUrl: widget.images[index],
                        fit: BoxFit.contain,
                        placeholder: (context, url) =>
                            const Center(child: ShimmerListTile()),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[900],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, color: Colors.white54, size: 48),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Back / Close button
                if (_showControls)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + AppSpacing.lg,
                    left: isDesktop ? null : AppSpacing.lg,
                    right: isDesktop ? AppSpacing.xl : null,
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _isHoveringClose = true),
                      onExit: (_) => setState(() => _isHoveringClose = false),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _isHoveringClose ? Colors.white : Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(isDesktop ? AppSpacing.md : AppSpacing.sm),
                          child: Icon(
                            isDesktop ? Icons.close_rounded : Icons.arrow_back,
                            color: _isHoveringClose ? Colors.black : AppColors.textInverse,
                            size: isDesktop ? 24 : 20,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Image count indicator
                if (_showControls)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + AppSpacing.lg,
                    left: isDesktop ? AppSpacing.xl : null,
                    right: isDesktop ? null : AppSpacing.lg,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Text(
                        '${_currentPage + 1} / ${widget.images.length}',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textInverse,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),

                // Desktop Navigation Arrows
                if (isDesktop && _showControls && widget.images.length > 1) ...[
                  // Previous arrow
                  if (_currentPage > 0)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.xxxl),
                        child: MouseRegion(
                          onEnter: (_) => setState(() => _isHoveringLeft = true),
                          onExit: (_) => setState(() => _isHoveringLeft = false),
                          child: GestureDetector(
                            onTap: _previousPage,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isHoveringLeft ? Colors.white : Colors.black.withOpacity(0.3),
                                border: Border.all(color: Colors.white38, width: 1),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: _isHoveringLeft ? Colors.black : Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Next arrow
                  if (_currentPage < widget.images.length - 1)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xxxl),
                        child: MouseRegion(
                          onEnter: (_) => setState(() => _isHoveringRight = true),
                          onExit: (_) => setState(() => _isHoveringRight = false),
                          child: GestureDetector(
                            onTap: _nextPage,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isHoveringRight ? Colors.white : Colors.black.withOpacity(0.3),
                                border: Border.all(color: Colors.white38, width: 1),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: _isHoveringRight ? Colors.black : Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],

                // Page indicators (Bottom dots)
                if (_showControls && widget.images.length > 1)
                  Positioned(
                    bottom: isDesktop ? AppSpacing.xxxl : AppSpacing.lg + MediaQuery.of(context).padding.bottom,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDesktop ? Colors.black.withOpacity(0.4) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.images.length,
                            (index) => GestureDetector(
                              onTap: isDesktop 
                                ? () => _pageController.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut)
                                : null,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: _currentPage == index ? (isDesktop ? 32 : 24) : 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? AppColors.primaryLight
                                      : Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
