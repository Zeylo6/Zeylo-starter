import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// ZeyloButton widget with filled and outlined variants
///
/// Supports:
/// - Filled variant (purple background, white text)
/// - Outlined variant (purple border, purple text)
/// - Loading state with circular progress indicator
/// - Disabled state (50% opacity)
/// - Full-width by default
/// - Optional leading icon
///
/// Example:
/// ```dart
/// ZeyloButton(
///   onPressed: () => print('Button pressed'),
///   label: 'Continue',
///   variant: ButtonVariant.filled,
/// )
/// ```
class ZeyloButton extends StatelessWidget {
  /// The callback triggered when the button is pressed
  final VoidCallback? onPressed;

  /// The button label text
  final String label;

  /// The button variant (filled or outlined)
  final ButtonVariant variant;

  /// Whether the button is in loading state
  final bool isLoading;

  /// Whether the button is disabled
  final bool isDisabled;

  /// Optional leading icon widget
  final Widget? icon;

  /// The button width. Defaults to full width (double.infinity)
  final double? width;

  /// The button height. Defaults to 52
  final double height;

  /// Border radius for the button. Defaults to 16 (pill-like)
  final double borderRadius;

  const ZeyloButton({
    required this.onPressed,
    required this.label,
    this.variant = ButtonVariant.filled,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.height = 52,
    this.borderRadius = AppRadius.lg,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isDisabled && onPressed != null && !isLoading;
    final effectiveOnPressed = isEnabled ? onPressed : null;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: _buildButton(isEnabled, effectiveOnPressed),
    );
  }

  Widget _buildButton(bool isEnabled, VoidCallback? onPressed) {
    return switch (variant) {
      ButtonVariant.filled => _buildFilledButton(isEnabled, onPressed),
      ButtonVariant.outlined => _buildOutlinedButton(isEnabled, onPressed),
    };
  }

  Widget _buildFilledButton(bool isEnabled, VoidCallback? onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          decoration: BoxDecoration(
            color: isEnabled
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.5),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.textInverse),
                      strokeWidth: 2.5,
                    ),
                  )
                : _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(bool isEnabled, VoidCallback? onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
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
                : _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final textColor = variant == ButtonVariant.filled
        ? AppColors.textInverse
        : AppColors.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(color: textColor),
        ),
      ],
    );
  }
}

/// Button variant enumeration
enum ButtonVariant {
  filled,
  outlined,
}
