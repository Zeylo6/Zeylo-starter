import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Glassmorphism social login button
class SocialLoginButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;
  final Widget icon;
  final bool isLoading;
  final double height;
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? onTap : null,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(isEnabled ? 0.55 : 0.35),
                      Colors.white.withOpacity(isEnabled ? 0.3 : 0.18),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: isEnabled
                        ? AppColors.primary.withOpacity(0.25)
                        : AppColors.primary.withOpacity(0.12),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 24, height: 24, child: icon),
                            const SizedBox(width: AppSpacing.md),
                            Text(label, style: AppTypography.labelLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
