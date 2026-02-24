import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../widgets/credit_card_widget.dart';

/// Payment success screen shown after successful payment completion
/// Based on Figma design "payment"
class PaymentSuccessScreen extends StatefulWidget {
  /// Card holder name
  final String cardholderName;

  /// Card number (last 4 digits for display)
  final String cardLastFour;

  /// Card expiry date
  final String expiryDate;

  /// Card type (Visa, Mastercard, Amex)
  final String cardType;

  /// Host name (who ended the session)
  final String hostName;

  /// Callback when continue is pressed
  final VoidCallback? onContinue;

  const PaymentSuccessScreen({
    required this.cardholderName,
    required this.cardLastFour,
    required this.expiryDate,
    required this.cardType,
    required this.hostName,
    this.onContinue,
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.xl),

            // Success Checkmark with animation
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.textInverse,
                  size: 60,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Completed Text
            Text(
              'Completed!',
              style: AppTypography.headlineLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Status Message
            Text(
              'Your host has ended the session.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Card Display
            CreditCardWidget(
              cardholderName: widget.cardholderName,
              cardNumber: '•••• •••• •••• ${widget.cardLastFour}',
              expiryDate: widget.expiryDate,
              cardType: widget.cardType,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Processing Status
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.primaryLight.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Loading spinner
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Processing text
                  Text(
                    'Processing payment automatically...',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Payment Details
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Confirmation',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildDetailRow(
                    'Card Type',
                    widget.cardType,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildDetailRow(
                    'Cardholder',
                    widget.cardholderName,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildDetailRow(
                    'Last 4 Digits',
                    widget.cardLastFour,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildDetailRow(
                    'Expires',
                    widget.expiryDate,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Divider(
                      color: AppColors.divider,
                      height: 1,
                    ),
                  ),
                  _buildDetailRow(
                    'Status',
                    'Completed',
                    valueColor: AppColors.success,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Continue Button
            ZeyloButton(
              onPressed: () {
                widget.onContinue?.call();
                Navigator.pop(context);
              },
              label: 'Continue',
              variant: ButtonVariant.filled,
              height: 52,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
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
          style: AppTypography.bodyMedium.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
