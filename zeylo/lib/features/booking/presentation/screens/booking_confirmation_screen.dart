import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';

/// Booking confirmation screen shown after successful booking
class BookingConfirmationScreen extends StatelessWidget {
  /// Booking ID
  final String bookingId;

  /// Experience title
  final String experienceTitle;

  /// Booking date
  final String bookingDate;

  /// Number of guests
  final int guests;

  /// Total price
  final double totalPrice;

  /// Callback when user wants to go back or continue
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
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textInverse,
              size: 24,
            ),
          ),
        ),
        title: Text(
          'Booking Confirmed',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.primary,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.xl),

            // Success Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Success Message
            Text(
              'Booking Confirmed!',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Confirmation Text
            Text(
              'Your booking has been successfully confirmed.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Booking Details Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Booking ID', bookingId),
                  const Divider(color: AppColors.divider, height: 24),
                  _buildDetailRow('Experience', experienceTitle),
                  const SizedBox(height: AppSpacing.md),
                  _buildDetailRow('Date', bookingDate),
                  const SizedBox(height: AppSpacing.md),
                  _buildDetailRow(
                    'Guests',
                    '$guests ${guests == 1 ? 'guest' : 'guests'}',
                  ),
                  const Divider(color: AppColors.divider, height: 24),
                  _buildDetailRow(
                    'Total Amount',
                    'Rs. ${totalPrice.toStringAsFixed(0)}',
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Next Steps
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What\'s Next?',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildNextStepItem(
                    '1',
                    'Check your email',
                    'A confirmation email has been sent to you',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildNextStepItem(
                    '2',
                    'Contact the host',
                    'Reach out to confirm additional details',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildNextStepItem(
                    '3',
                    'Prepare for your experience',
                    'Get ready for an amazing adventure!',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Continue Button
            ZeyloButton(
              onPressed: () {
                onContinue?.call();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              label: 'Continue Browsing',
              variant: ButtonVariant.filled,
              height: 52,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: isBold
              ? AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                )
              : AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
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
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTypography.labelLarge.copyWith(
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
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
