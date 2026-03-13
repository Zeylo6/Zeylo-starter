import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../../features/auth/domain/entities/user_entity.dart';

/// A premium glassmorphism capsule used to identify the user's active role.
class RoleCapsule extends StatelessWidget {
  final UserRole role;
  final bool showLabel;

  const RoleCapsule({
    required this.role,
    this.showLabel = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getRoleConfig(role);

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh.withOpacity(0.8),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: config.color.withOpacity(0.2),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: config.color.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                config.icon,
                size: 14,
                color: config.color,
              ),
              if (showLabel) ...[
                const SizedBox(width: 6),
                Text(
                  config.label,
                  style: AppTypography.labelSmall.copyWith(
                    color: config.color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _RoleConfig _getRoleConfig(UserRole role) {
    return switch (role) {
      UserRole.seeker => const _RoleConfig(
          label: 'SEEKER',
          icon: Icons.explore_rounded,
          color: AppColors.primary,
        ),
      UserRole.host => const _RoleConfig(
          label: 'HOST',
          icon: Icons.home_rounded,
          color: AppColors.success,
        ),
      UserRole.business => const _RoleConfig(
          label: 'BUSINESS',
          icon: Icons.business_center_rounded,
          color: Color(0xFF3B82F6), // Blue 500
        ),
      UserRole.admin => const _RoleConfig(
          label: 'ADMIN',
          icon: Icons.admin_panel_settings_rounded,
          color: AppColors.textPrimary,
        ),
    };
  }
}

class _RoleConfig {
  final String label;
  final IconData icon;
  final Color color;

  const _RoleConfig({
    required this.label,
    required this.icon,
    required this.color,
  });
}
