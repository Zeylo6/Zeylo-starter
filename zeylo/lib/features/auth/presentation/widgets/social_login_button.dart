import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Social login button for Apple and Google authentication
///
/// Features:
/// - Outlined style with icon support
/// - Displays provider name (Apple or Google)
/// - Loading state support
/// - Full width by default
///
/// Example:
/// ```dart
/// SocialLoginButton(
///   icon: Image.asset('assets/google_icon.png'),
///   label: 'Login with Google',
///   onTap: () => print('Google login'),
/// )
/// ```
class SocialLoginButton extends StatelessWidget {
  /// The callback triggered when button is tapped
  final VoidCallback? onTap;

  /// The button label text
  final String label;

  /// The icon widget to display
  final Widget icon;

  /// Whether the button is in loading state
  final bool isLoading;

  /// Button height (default 52)
  final double height;

  /// Border radius (default 16)
  final double borderRadius;

  const SocialLoginButton({
    required this.onTap,
    required this.label,
    required this.icon,
    this.isLoading = false,
    this.height = 52,
    this.borderRadius = AppRadius.lg,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isLoading && onTap != null;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isEnabled
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.5),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: icon,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          label,
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
