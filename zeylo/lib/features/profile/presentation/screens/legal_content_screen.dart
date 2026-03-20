import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

enum LegalContentType { privacyPolicy, termsOfService }

class LegalContentScreen extends StatelessWidget {
  final LegalContentType type;

  const LegalContentScreen({
    required this.type,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isPrivacy = type == LegalContentType.privacyPolicy;
    final title = isPrivacy ? 'Privacy Policy' : 'Terms of Service';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: AppTypography.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Updated: March 20, 2026',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (isPrivacy)
              _buildPrivacyPolicy()
            else
              _buildTermsOfService(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('1. Information Collection'),
        _buildParagraph(
          'We collect information you provide directly to us when you create an account, create an experience, or communicate with us. This includes your name, email address, phone number, and profile picture.',
        ),
        _buildSectionTitle('2. Use of Information'),
        _buildParagraph(
          'We use the information we collect to provide, maintain, and improve our services, facilitate bookings between seekers and hosts, and send you technical notices and support messages.',
        ),
        _buildSectionTitle('3. Sharing of Information'),
        _buildParagraph(
          'We share information between seekers and hosts to facilitate bookings. We do not sell your personal information to third parties.',
        ),
        _buildSectionTitle('4. Security'),
        _buildParagraph(
          'We take reasonable measures to help protect information about you from loss, theft, misuse, and unauthorized access.',
        ),
        _buildSectionTitle('5. Contact Us'),
        _buildParagraph(
          'If you have any questions about this Privacy Policy, please contact us at support@zeylo.com.',
        ),
      ],
    );
  }

  Widget _buildTermsOfService() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('1. Acceptance of Terms'),
        _buildParagraph(
          'By accessing or using the Zeylo application, you agree to be bound by these Terms of Service. If you do not agree to all of these terms, do not use the application.',
        ),
        _buildSectionTitle('2. Eligibility'),
        _buildParagraph(
          'You must be at least 18 years of age to use Zeylo. By using Zeylo, you represent and warrant that you meet this requirement.',
        ),
        _buildSectionTitle('3. User Conduct'),
        _buildParagraph(
          'You are responsible for your conduct and any content you post to Zeylo. You agree not to use Zeylo for any unlawful or prohibited purpose.',
        ),
        _buildSectionTitle('4. Booking and Payments'),
        _buildParagraph(
          'Zeylo facilitates bookings between seekers and hosts. Payments are processed through our designated payment partners. Zeylo is not responsible for the quality of experiences provided by hosts.',
        ),
        _buildSectionTitle('5. Termination'),
        _buildParagraph(
          'We reserve the right to terminate or suspend your account at any time, without notice, for conduct that we believe violates these Terms.',
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }
}
