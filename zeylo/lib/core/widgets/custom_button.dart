import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// ZeyloButton with glassmorphism aesthetic
///
/// Filled variant: purple gradient with glow shadow
/// Outlined variant: glass background with translucent border
class ZeyloButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final double? width;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;

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
    this.backgroundColor,
    super.key,
  });

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
            gradient: isEnabled
                ? (backgroundColor != null
                    ? LinearGradient(colors: [backgroundColor!, backgroundColor!])
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.gradientEnd.withOpacity(0.85),
                        ],
                      ))
                : LinearGradient(
                    colors: [
                      (backgroundColor ?? AppColors.primary).withOpacity(0.4),
                      (backgroundColor ?? AppColors.primary).withOpacity(0.3),
                    ],
                  ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(isEnabled ? 0.2 : 0.1),
              width: 1,
            ),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: (backgroundColor ?? AppColors.primary)
                          .withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textInverse),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(isEnabled ? 0.5 : 0.3),
                    Colors.white.withOpacity(isEnabled ? 0.25 : 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: isEnabled
                      ? AppColors.primary.withOpacity(0.3)
                      : AppColors.primary.withOpacity(0.15),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary),
                          strokeWidth: 2.5,
                        ),
                      )
                    : _buildContent(),
              ),
            ),
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
          style: AppTypography.labelLarge.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
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
