import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// ZeyloErrorWidget - Error state display widget
///
/// Features:
/// - Customizable icon (red color by default)
/// - Error message text
/// - "Try Again" button with callback
/// - Customizable appearance
///
/// Example:
/// ```dart
/// ZeyloErrorWidget(
///   title: 'Something went wrong',
///   message: 'Please check your connection and try again',
///   icon: Icons.error,
///   onTryAgain: () => retryFetch(),
/// )
/// ```
class ZeyloErrorWidget extends StatelessWidget {
  /// Error title text
  final String title;

  /// Error message text
  final String message;

  /// Icon to display (red by default)
  final IconData icon;

  /// Icon color
  final Color iconColor;

  /// Icon size
  final double iconSize;

  /// Callback for "Try Again" button
  final VoidCallback? onTryAgain;

  /// Whether to show "Try Again" button
  final bool showTryAgainButton;

  /// Button label text
  final String tryAgainLabel;

  /// Whether to center the content
  final bool centered;

  /// Padding
  final EdgeInsets padding;

  const ZeyloErrorWidget({
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
    this.iconColor = AppColors.error,
    this.iconSize = 64,
    this.onTryAgain,
    this.showTryAgainButton = true,
    this.tryAgainLabel = 'Try Again',
    this.centered = true,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment:
          centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        // Icon
        Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
        const SizedBox(height: AppSpacing.lg),
        // Title
        Text(
          title,
          style: AppTypography.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        // Message
        Text(
          message,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        if (showTryAgainButton && onTryAgain != null) ...[
          const SizedBox(height: AppSpacing.xl),
          // Try Again Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTryAgain,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Center(
                    child: Text(
                      tryAgainLabel,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textInverse,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );

    if (centered) {
      return Center(
        child: Padding(
          padding: padding,
          child: content,
        ),
      );
    }

    return Padding(
      padding: padding,
      child: content,
    );
  }
}

/// ZeyloNoDataWidget - Specific variant for no data errors
class ZeyloNoDataWidget extends StatelessWidget {
  /// Error title text
  final String title;

  /// Error message text
  final String message;

  /// Whether to center the content
  final bool centered;

  /// Padding
  final EdgeInsets padding;

  const ZeyloNoDataWidget({
    this.title = 'No Data Found',
    this.message = 'There is no data available at the moment.',
    this.centered = true,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ZeyloErrorWidget(
      title: title,
      message: message,
      icon: Icons.inbox_outlined,
      iconColor: AppColors.textSecondary,
      showTryAgainButton: false,
      centered: centered,
      padding: padding,
    );
  }
}

/// ZeyloNetworkErrorWidget - Specific variant for network errors
class ZeyloNetworkErrorWidget extends StatelessWidget {
  /// Callback for "Try Again" button
  final VoidCallback? onTryAgain;

  /// Whether to center the content
  final bool centered;

  /// Padding
  final EdgeInsets padding;

  const ZeyloNetworkErrorWidget({
    this.onTryAgain,
    this.centered = true,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ZeyloErrorWidget(
      title: 'Connection Error',
      message:
          'Unable to connect to the internet. Please check your connection and try again.',
      icon: Icons.wifi_off_outlined,
      onTryAgain: onTryAgain,
      centered: centered,
      padding: padding,
    );
  }
}
