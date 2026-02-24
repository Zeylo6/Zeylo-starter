import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// ZeyloBottomNavBar - Bottom navigation bar with 4 icon items
///
/// Features:
/// - 4 icon items: Home, Discover, Explore, Profile
/// - Selected item has purple color, unselected is grey
/// - Icon-only based on Figma design
/// - Clean white background with top border
/// - Uses currentIndex and onTap callback
///
/// Example:
/// ```dart
/// ZeyloBottomNavBar(
///   currentIndex: 0,
///   onTap: (index) {
///     setState(() {
///       _currentIndex = index;
///     });
///   },
/// )
/// ```
class ZeyloBottomNavBar extends StatelessWidget {
  /// Currently selected tab index (0-3)
  final int currentIndex;

  /// Callback when tab is tapped
  final ValueChanged<int> onTap;

  /// Bottom safe area padding
  final double bottomPadding;

  /// Icon size
  final double iconSize;

  const ZeyloBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    this.bottomPadding = 0,
    this.iconSize = 24,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          0,
          AppSpacing.md,
          0,
          AppSpacing.md + bottomPadding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.home_outlined, 'Home'),
            _buildNavItem(1, Icons.auto_awesome_outlined, 'Discover'),
            _buildNavItem(2, Icons.link_outlined, 'Explore'),
            _buildNavItem(3, Icons.account_circle_outlined, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Semantics(
        button: true,
        enabled: true,
        label: label,
        child: Icon(
          icon,
          size: iconSize,
          color: color,
        ),
      ),
    );
  }
}
