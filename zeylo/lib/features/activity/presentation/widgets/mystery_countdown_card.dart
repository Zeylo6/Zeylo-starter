import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/activity_entity.dart';

/// Widget displaying a mystery experience card with countdown timer
class MysteryCountdownCard extends StatefulWidget {
  /// The mystery activity
  final UserActivity activity;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  const MysteryCountdownCard({
    required this.activity,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  State<MysteryCountdownCard> createState() => _MysteryCountdownCardState();
}

class _MysteryCountdownCardState extends State<MysteryCountdownCard> {
  late DateTime unlockTime;

  @override
  void initState() {
    super.initState();
    unlockTime = widget.activity.mysteryUnlockTime ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.border.withOpacity(0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lock icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface.withOpacity(0.1),
              ),
              child: Icon(
                Icons.lock_outlined,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Title with gradient
            ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  colors: [
                    Color(0xFF8B5CF6), // Purple
                    Color(0xFFA855F7), // Pink-purple
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: Text(
                'Mystery Experience',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textInverse,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Subtitle
            Text(
              'Your surprise adventure awaits. Details will be revealed 24 hours before start.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.lg),
            // Countdown timer
            _buildCountdownTimer(),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownTimer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unlocks in',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _CountdownDisplay(unlockTime: unlockTime),
      ],
    );
  }
}

/// Widget that displays the countdown timer
class _CountdownDisplay extends StatefulWidget {
  final DateTime unlockTime;

  const _CountdownDisplay({
    required this.unlockTime,
  });

  @override
  State<_CountdownDisplay> createState() => _CountdownDisplayState();
}

class _CountdownDisplayState extends State<_CountdownDisplay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Update every second
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = widget.unlockTime.difference(now);

    String hours = difference.inHours.toString().padLeft(2, '0');
    String minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');

    return Text(
      '$hours : $minutes : $seconds',
      style: AppTypography.titleLarge.copyWith(
        color: AppColors.primary,
        fontFamily: 'monospace',
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );
  }
}
