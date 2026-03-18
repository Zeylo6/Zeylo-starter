import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';

/// Email verification success screen
///
/// Displayed after successful email verification.
/// Auto-navigates to home after 3 seconds with animated progress.
class VerifySuccessScreen extends StatefulWidget {
  const VerifySuccessScreen({super.key});

  @override
  State<VerifySuccessScreen> createState() => _VerifySuccessScreenState();
}

class _VerifySuccessScreenState extends State<VerifySuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _progressController;
  late Animation<double> _checkScale;
  late Animation<double> _checkOpacity;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );
    _checkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _checkController,
          curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _checkController.forward();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _progressController.forward();
    });

    _navigateToHome();
  }

  @override
  void dispose() {
    _checkController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) context.go('/home');
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Animated success icon
          ScaleTransition(
            scale: _checkScale,
            child: FadeTransition(
              opacity: _checkOpacity,
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.success, Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.35),
                      blurRadius: 32,
                      spreadRadius: 6,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 56,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Title
          Text(
            'Email Verified!',
            style: AppTypography.displayMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),

          Text(
            'Your account is ready. Welcome to Zeylo!',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // Animated progress bar + redirect notice
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Redirecting you to home…',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, _) => LinearProgressIndicator(
                      value: _progressController.value,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                      minHeight: 5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Manual CTA
          SizedBox(
            width: double.infinity,
            child: ZeyloButton(
              onPressed: () => context.go('/home'),
              label: 'Go to Home',
              variant: ButtonVariant.filled,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 800) {
              // ── Desktop: two-panel layout ──
              return Row(
                children: [
                  // Left branded panel
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.success, Color(0xFF047857)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.blur_on_rounded,
                                  size: 56, color: Colors.white),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              "You're all set!",
                              style: AppTypography.displayLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your Zeylo account is verified and ready to go. Start exploring experiences, connecting with your community, and making memories.',
                              style: AppTypography.bodyLarge.copyWith(
                                color: Colors.white.withOpacity(0.85),
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 48),
                            // Feature highlights
                            _buildHighlight(
                                Icons.explore_rounded, 'Discover Experiences'),
                            const SizedBox(height: 16),
                            _buildHighlight(
                                Icons.people_rounded, 'Connect with Community'),
                            const SizedBox(height: 16),
                            _buildHighlight(
                                Icons.calendar_month_rounded, 'Book & Manage'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Right content panel
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: _buildContent(),
                      ),
                    ),
                  ),
                ],
              );
            }

            // ── Mobile layout ──
            return _buildContent();
          },
        ),
      ),
    );
  }

  Widget _buildHighlight(IconData icon, String label) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: AppTypography.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
