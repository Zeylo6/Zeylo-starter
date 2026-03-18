import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';

/// Account banned / restricted screen
///
/// Shown when a user's account has been permanently restricted.
/// Provides a reason (if available) and options to contact support or sign out.
class BannedScreen extends StatelessWidget {
  final String? reason;

  const BannedScreen({super.key, this.reason});

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Future<void> _contactSupport(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'officialzeylolk@gmail.com',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Appeal for Account Restriction',
        'body':
            'Hello Zeylo Support,\n\nI would like to appeal the restriction of my account. [Please add your explanation here]'
      }),
    );

    try {
      final bool launched = await launchUrl(
        emailLaunchUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Could not open email app. Please contact officialzeylolk@gmail.com directly.'),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('An error occurred. Please contact officialzeylolk@gmail.com'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Error icon
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.error.withOpacity(0.12),
                  AppColors.error.withOpacity(0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.error.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.block_rounded,
              color: AppColors.error,
              size: 48,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Title
          Text(
            'Account Restricted',
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),

          // Subtitle
          Text(
            'After reviewing your account activity, we determined that your conduct violated our Community Guidelines. Your access to Zeylo has been permanently revoked.',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Reason card — shown only when a reason is provided
          if (reason != null && reason!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.04),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.error.withOpacity(0.18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.report_outlined,
                          size: 16,
                          color: AppColors.error.withOpacity(0.75)),
                      const SizedBox(width: 8),
                      Text(
                        'REASON FOR RESTRICTION',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.error.withOpacity(0.75),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    reason!,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],

          // What you can do section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What can I do?',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildInfoRow(
                  Icons.mail_outline_rounded,
                  'Contact our support team to submit an appeal.',
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildInfoRow(
                  Icons.gavel_rounded,
                  'Review our Community Guidelines to understand the policy.',
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildInfoRow(
                  Icons.timer_outlined,
                  'Appeals are reviewed within 3–5 business days.',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // Primary CTA
          SizedBox(
            width: double.infinity,
            child: ZeyloButton(
              label: 'Contact Support',
              onPressed: () => _contactSupport(context),
              width: double.infinity,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Sign out
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout_rounded,
                  size: 18, color: AppColors.textSecondary),
              label: Text(
                'Sign out of this account',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
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
                  // Left dark branded panel
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1E0A0A), Color(0xFF3B0F0F)],
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
                                color: AppColors.error.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.blur_on_rounded,
                                  size: 56, color: Colors.white),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Zeylo',
                              style: AppTypography.displayLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Community Standards',
                              style: AppTypography.headlineSmall.copyWith(
                                color: AppColors.error.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'We believe in keeping Zeylo a safe, inclusive, and respectful place for everyone. Our guidelines exist to protect our community.',
                              style: AppTypography.bodyLarge.copyWith(
                                color: Colors.white.withOpacity(0.7),
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 48),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.support_agent_rounded,
                                      color: Colors.white, size: 32),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'Our support team is here to help. Reach out and we\'ll review your case fairly.',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: Colors.white.withOpacity(0.8),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: _buildContent(context),
                      ),
                    ),
                  ),
                ],
              );
            }

            // ── Mobile layout ──
            return _buildContent(context);
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textHint),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
