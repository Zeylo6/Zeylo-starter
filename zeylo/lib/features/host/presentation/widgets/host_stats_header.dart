import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/host_avatar.dart';
import '../../domain/entities/host_stats_entity.dart';

/// Host stats header widget with premium glassy design
class HostStatsHeader extends StatelessWidget {
  final String hostName;
  final String? hostPhotoUrl;
  final bool isSuperhost;
  final double thisMonthEarnings;
  final double averageRating;
  final HostStatsEntity stats;

  const HostStatsHeader({
    required this.hostName,
    this.hostPhotoUrl,
    this.isSuperhost = false,
    required this.thisMonthEarnings,
    required this.averageRating,
    required this.stats,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Host info row
              Row(
                children: [
                  HostAvatar(
                    imageUrl: hostPhotoUrl,
                    hostName: hostName,
                    size: AvatarSize.medium,
                    isVerified: true,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Welcome back,',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          hostName,
                          style: AppTypography.headlineSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSuperhost)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Superhost',
                            style: AppTypography.labelSmall.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Stats cards row
              Row(
                children: [
                  _StatCard(
                    label: 'Earnings',
                    value: 'LKR ${thisMonthEarnings.toStringAsFixed(0)}',
                    icon: Icons.payments_outlined,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'Rating',
                    value: averageRating.toStringAsFixed(1),
                    icon: Icons.star_rounded,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'Reviews',
                    value: '${stats.totalBookings}',
                    icon: Icons.chat_bubble_outline,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual stat card with glassmorphism
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.7), size: 18),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTypography.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
