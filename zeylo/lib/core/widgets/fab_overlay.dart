import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Floating action button overlay with action buttons in a cluster
class FABOverlay extends StatefulWidget {
  /// Whether the overlay is visible
  final bool isVisible;

  /// Callback when overlay is dismissed
  final VoidCallback? onDismiss;

  /// Callback for sparkle/magic action
  final VoidCallback? onSparkle;

  /// Callback for community/people action
  final VoidCallback? onCommunity;

  /// Callback for voice/mic action
  final VoidCallback? onVoice;

  /// Callback for map/search action
  final VoidCallback? onMapSearch;

  /// Callback for mystery/gift action
  final VoidCallback? onMystery;

  const FABOverlay({
    required this.isVisible,
    this.onDismiss,
    this.onSparkle,
    this.onCommunity,
    this.onVoice,
    this.onMapSearch,
    this.onMystery,
    super.key,
  });

  @override
  State<FABOverlay> createState() => _FABOverlayState();
}

class _FABOverlayState extends State<FABOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(FABOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _animationController.forward();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Overlay background
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              _animationController.reverse().then((_) {
                widget.onDismiss?.call();
              });
            },
            child: AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Container(
                  color: Colors.black.withOpacity(0.5 * _opacityAnimation.value),
                );
              },
            ),
          ),
        ),
        // FAB cluster
        Positioned(
          bottom: 80,
          right: AppSpacing.lg,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: _buildFABCluster(),
          ),
        ),
      ],
    );
  }

  Widget _buildFABCluster() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Sparkle (top-left of cluster)
        Positioned(
          left: -60,
          top: -60,
          child: _buildFABButton(
            icon: Icons.auto_awesome,
            label: 'Magic',
            onTap: widget.onSparkle,
          ),
        ),
        // Community (center-left)
        Positioned(
          left: -80,
          top: 0,
          child: _buildFABButton(
            icon: Icons.people,
            label: 'Community',
            onTap: widget.onCommunity,
          ),
        ),
        // Voice (center)
        Positioned(
          top: -70,
          child: _buildFABButton(
            icon: Icons.mic,
            label: 'Voice',
            onTap: widget.onVoice,
          ),
        ),
        // Map Search (bottom-left)
        Positioned(
          left: -60,
          bottom: -60,
          child: _buildFABButton(
            icon: Icons.map,
            label: 'Explore',
            onTap: widget.onMapSearch,
          ),
        ),
        // Mystery (bottom-right)
        Positioned(
          right: -60,
          bottom: -60,
          child: _buildFABButton(
            icon: Icons.card_giftcard,
            label: 'Mystery',
            onTap: widget.onMystery,
          ),
        ),
      ],
    );
  }

  Widget _buildFABButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            _animationController.reverse().then((_) {
              onTap?.call();
            });
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppColors.textInverse,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// State container for FAB overlay management
class FABOverlayContainer extends StatefulWidget {
  /// The main content
  final Widget child;

  /// Whether to show the bottom nav bar
  final bool showBottomNav;

  const FABOverlayContainer({
    required this.child,
    this.showBottomNav = true,
    super.key,
  });

  @override
  State<FABOverlayContainer> createState() => _FABOverlayContainerState();
}

class _FABOverlayContainerState extends State<FABOverlayContainer> {
  bool _showFABOverlay = false;

  void _toggleFABOverlay() {
    setState(() => _showFABOverlay = !_showFABOverlay);
  }

  void _closeFABOverlay() {
    setState(() => _showFABOverlay = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // FAB overlay
        FABOverlay(
          isVisible: _showFABOverlay,
          onDismiss: _closeFABOverlay,
          onSparkle: () {
            _closeFABOverlay();
            // Handle sparkle/magic action
          },
          onCommunity: () {
            _closeFABOverlay();
            // Handle community action
          },
          onVoice: () {
            _closeFABOverlay();
            // Handle voice action
          },
          onMapSearch: () {
            _closeFABOverlay();
            // Handle map search action
          },
          onMystery: () {
            _closeFABOverlay();
            // Handle mystery action
          },
        ),
        // Main FAB button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _toggleFABOverlay,
            backgroundColor: AppColors.primary,
            shape: const CircleBorder(),
            child: Icon(
              _showFABOverlay ? Icons.close : Icons.add,
              color: AppColors.textInverse,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}
