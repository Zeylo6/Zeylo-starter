import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  Timer? _autoCheckTimer;
  bool _isChecking = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _sendInitialEmail();
    _startAutoCheck();
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
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
            const SnackBar(
              content: Text('Email not yet verified. Please check your inbox and click the link.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
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
          const SnackBar(content: Text('Verification email sent! Check your inbox.'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
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

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF3EEFF), Color(0xFFF9F7FF), Color(0xFFEDE9FE), Color(0xFFF5F3FF)],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -40, right: -30,
              child: Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.0)]))),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _signOut,
                        child: Text('Sign Out', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Glass mail icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.15), AppColors.gradientEnd.withOpacity(0.08)]),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 20, spreadRadius: 2)],
                      ),
                      child: const Icon(Icons.mail_outline_rounded, size: 40, color: AppColors.primary),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text('Verify Your Email', style: AppTypography.headlineLarge.copyWith(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.md),
                    Text("We've sent a verification link to", style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.sm),
                    // Glass email badge
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.1), AppColors.gradientEnd.withOpacity(0.05)]),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
                          ),
                          child: Text(email, style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text('Click the link in your email to verify your account. This page will update automatically.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.xxxl),
                    ZeyloButton(onPressed: _isChecking ? null : _manualCheck, label: "I've Verified My Email", isLoading: _isChecking, variant: ButtonVariant.filled),
                    const SizedBox(height: AppSpacing.xxl),
                    GestureDetector(
                      onTap: _isResending ? null : _resendEmail,
                      child: _isResending
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: "Didn't receive the email? ",
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                                children: [
                                  TextSpan(text: 'Resend', style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
