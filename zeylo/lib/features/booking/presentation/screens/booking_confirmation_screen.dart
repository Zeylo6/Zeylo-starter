import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';

/// Booking confirmation screen shown after successful booking
/// Refactored for Web responsive layout: Maximum width of 600px, horizontally centered inside a card on desktop.
class BookingConfirmationScreen extends StatelessWidget {
  final String bookingId;
  final String experienceTitle;
  final String bookingDate;
  final int guests;
  final double totalPrice;
  final VoidCallback? onContinue;

  const BookingConfirmationScreen({
    required this.bookingId,
    required this.experienceTitle,
    required this.bookingDate,
    required this.guests,
    required this.totalPrice,
    this.onContinue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(AppSpacing.sm),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: AppColors.textInverse, size: 24),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xl,
            horizontal: AppSpacing.lg,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _buildConfirmationCard(context),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationCard(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    
    return Container(
      padding: EdgeInsets.all(isDesktop ? AppSpacing.xxxl : AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          if (isDesktop)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 40,
              offset: const Offset(0, 10),
            )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Success Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: AppColors.success, size: 56),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Success Message
          Text(
            'Booking Confirmed!',
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Confirmation Text
          Text(
            'Your booking has been successfully confirmed.',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Booking Details Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Booking ID', bookingId),
                const Divider(color: AppColors.divider, height: 32),
                _buildDetailRow('Experience', experienceTitle),
                const SizedBox(height: AppSpacing.md),
                _buildDetailRow('Date', bookingDate),
                const SizedBox(height: AppSpacing.md),
                _buildDetailRow('Guests', '$guests ${guests == 1 ? 'guest' : 'guests'}'),
                const Divider(color: AppColors.divider, height: 32),
                _buildDetailRow(
                  'Total Amount',
                  'Rs. ${totalPrice.toStringAsFixed(0)}',
                  isBold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Next Steps
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What\'s Next?',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildNextStepItem('1', 'Check your email', 'A confirmation email has been sent to you'),
                const SizedBox(height: AppSpacing.md),
                _buildNextStepItem('2', 'Contact the host', 'Reach out to confirm additional details'),
                const SizedBox(height: AppSpacing.md),
                _buildNextStepItem('3', 'Prepare for your experience', 'Get ready for an amazing adventure!'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // Continue Button
          ZeyloButton(
            onPressed: () {
              onContinue?.call();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            label: 'Continue Browsing',
            variant: ButtonVariant.filled,
            height: 56,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: isBold
                ? AppTypography.headlineSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)
                : AppTypography.titleMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildNextStepItem(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textInverse,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
