import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

/// Email verification screen
///
/// Shows a "check your email" message after signup/login.
/// Automatically sends a verification email on load if needed.
/// Periodically checks if the user has clicked the Firebase verification link.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen>
    with SingleTickerProviderStateMixin {
  Timer? _autoCheckTimer;
  bool _isChecking = false;
  bool _isResending = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _sendInitialEmail();
    _startAutoCheck();
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _sendInitialEmail() async {
    try {
      await ref.read(authNotifierProvider.notifier).sendVerificationEmail();
    } catch (_) {}
  }

  void _startAutoCheck() {
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (_isChecking) return;
      try {
        final verified =
            await ref.read(authNotifierProvider.notifier).checkEmailVerified();
        if (verified && mounted) {
          _autoCheckTimer?.cancel();
          context.go('/verify-success');
        }
      } catch (_) {}
    });
  }

  Future<void> _manualCheck() async {
    setState(() => _isChecking = true);
    try {
      final verified =
          await ref.read(authNotifierProvider.notifier).checkEmailVerified();
      if (mounted) {
        if (verified) {
          _autoCheckTimer?.cancel();
          context.go('/verify-success');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Email not yet verified. Please check your inbox and click the link.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _isResending = true);
    try {
      await ref.read(authNotifierProvider.notifier).resendVerificationEmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Verification email sent! Check your inbox.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _signOut() async {
    _autoCheckTimer?.cancel();
    await ref.read(authNotifierProvider.notifier).signOut();
    if (mounted) context.go('/login');
  }

  Widget _buildContent() {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Animated mail icon
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.primaryLight.withOpacity(0.25),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.mark_email_unread_rounded,
                size: 44,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Title
          Text(
            'Check Your Inbox',
            style: AppTypography.displayMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),

          // Subtitle
          Text(
            "We've sent a verification link to",
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Email chip
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mail_outline_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  email,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Info card
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: AppColors.primary.withOpacity(0.8), size: 20),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Click the link in your email to verify your account. This page checks automatically every few seconds.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // Primary CTA
          SizedBox(
            width: double.infinity,
            child: ZeyloButton(
              onPressed: _isChecking ? null : _manualCheck,
              label: "I've Verified My Email",
              isLoading: _isChecking,
              variant: ButtonVariant.filled,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Resend link
          GestureDetector(
            onTap: _isResending ? null : _resendEmail,
            child: _isResending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  )
                : RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "Didn't receive an email? ",
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: 'Resend',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Sign out link
          TextButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded,
                size: 16, color: AppColors.textHint),
            label: Text(
              'Sign out of this account',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
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
                          colors: [AppColors.primary, AppColors.primaryDark],
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
                            const Icon(Icons.blur_on_rounded,
                                size: 72, color: Colors.white),
                            const SizedBox(height: 32),
                            Text(
                              'Almost there!',
                              style: AppTypography.displayLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Just one more step to unlock the full Zeylo experience. Verify your email and start discovering amazing local experiences.',
                              style: AppTypography.bodyLarge.copyWith(
                                color: Colors.white.withOpacity(0.85),
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 48),
                            // Steps indicator
                            _buildStep(
                                Icons.person_outline_rounded, 'Account Created',
                                done: true),
                            const SizedBox(height: 16),
                            _buildStep(
                                Icons.mark_email_unread_rounded,
                                'Verify Email',
                                active: true),
                            const SizedBox(height: 16),
                            _buildStep(
                                Icons.explore_outlined, 'Start Exploring'),
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

  Widget _buildStep(IconData icon, String label,
      {bool done = false, bool active = false}) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: done
                ? Colors.white
                : active
                    ? Colors.white.withOpacity(0.25)
                    : Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: active
                  ? Colors.white
                  : Colors.white.withOpacity(done ? 0 : 0.3),
              width: active ? 2 : 1,
            ),
          ),
          child: Icon(
            done ? Icons.check_rounded : icon,
            size: 18,
            color: done ? AppColors.primary : Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTypography.titleMedium.copyWith(
            color: done || active
                ? Colors.white
                : Colors.white.withOpacity(0.55),
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
