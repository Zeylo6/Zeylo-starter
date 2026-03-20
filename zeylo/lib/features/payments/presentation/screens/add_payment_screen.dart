import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
// Removed unused import
import '../../../../core/services/stripe_payment_service.dart';
import '../widgets/credit_card_widget.dart';

/// Add payment screen for entering credit card details
/// Based on Figma design "iPhone 16 Pro Max - 27"
class AddPaymentScreen extends StatefulWidget {
  /// Callback when payment is confirmed
  final Function(
          String cardNumber, String expiry, String cvc, String cardholderName)?
      onPaymentConfirmed;

  const AddPaymentScreen({
    this.onPaymentConfirmed,
    super.key,
  });

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  late TextEditingController _cardNumberController;
  late TextEditingController _expiryController;
  late TextEditingController _cvcController;
  late TextEditingController _cardholderNameController;

  String? _cardNumberError;
  String? _expiryError;
  String? _cvcError;
  String? _cardholderError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController();
    _expiryController = TextEditingController();
    _cvcController = TextEditingController();
    _cardholderNameController = TextEditingController();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _cardholderNameController.dispose();
    super.dispose();
  }

  void _validateAndConfirm() {
    setState(() {
      _cardNumberError =
          Validators.validateCardNumber(_cardNumberController.text);
      _expiryError = Validators.validateExpiry(_expiryController.text);
      _cvcError = Validators.validateCVC(_cvcController.text);
      _cardholderError =
          Validators.validateRequired(_cardholderNameController.text);
    });

    if (_cardNumberError == null &&
        _expiryError == null &&
        _cvcError == null &&
        _cardholderError == null) {
      _submitPayment();
    }
  }

  void _submitPayment() async {
    setState(() => _isLoading = true);
    try {
      await StripePaymentService.makePayment(50.0, "current_booking_id", "test@example.com");
      // Handle success (navigate to success screen)
    } catch (e) {
      // Handle error (show snackbar)
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatCardNumber(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  String _formatExpiry(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';

    if (digits.length >= 2) {
      return '${digits.substring(0, 2)}/${digits.substring(2)}';
    }
    return digits;
  }

  String _getMaskedCardNumber() {
    final cardNumber = _cardNumberController.text.replaceAll(' ', '');
    if (cardNumber.isEmpty) {
      return '•••• •••• •••• ••••';
    }
    if (cardNumber.length <= 4) {
      return '•••• •••• •••• ${cardNumber.padRight(4, '•').substring(cardNumber.length).padLeft(4, '•')}';
    }
    final lastFour = cardNumber.substring(cardNumber.length - 4);
    return '•••• •••• •••• $lastFour';
  }

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
          'Add Payment Method',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.primary,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),

            // Card Preview
            CreditCardWidget(
              cardholderName: _cardholderNameController.text.isEmpty
                  ? 'CARD HOLDER'
                  : _cardholderNameController.text.toUpperCase(),
              cardNumber: _getMaskedCardNumber(),
              expiryDate: _expiryController.text.isEmpty
                  ? 'MM/YY'
                  : _expiryController.text,
              cardType: _getCardType(_cardNumberController.text),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Card Number Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Card Number',
                  style: AppTypography.labelLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildCardNumberField(),
              ],
            ),
            if (_cardNumberError != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                _cardNumberError!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),

            // Expiry and CVC Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expiry Date',
                        style: AppTypography.labelLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildExpiryField(),
                      if (_expiryError != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _expiryError!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CVC',
                        style: AppTypography.labelLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildCVCField(),
                      if (_cvcError != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _cvcError!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Cardholder Name
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cardholder Name',
                  style: AppTypography.labelLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildCardholderNameField(),
              ],
            ),
            if (_cardholderError != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                _cardholderError!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),

            // Security Message
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Payments are secure and encrypted',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Submit Button
            ZeyloButton(
              onPressed: _validateAndConfirm,
              label: 'Add Payment Method',
              variant: ButtonVariant.filled,
              isLoading: _isLoading,
              height: 52,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildCardNumberField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _cardNumberError != null ? AppColors.error : AppColors.border,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: TextField(
        controller: _cardNumberController,
        keyboardType: TextInputType.number,
        onChanged: (value) {
          final formatted = _formatCardNumber(value);
          _cardNumberController.value = _cardNumberController.value.copyWith(
            text: formatted,
            selection: TextSelection.fromPosition(
              TextPosition(offset: formatted.length),
            ),
          );
          if (_cardNumberError != null) {
            setState(() {
              _cardNumberError = Validators.validateCardNumber(formatted);
            });
          }
          setState(() {});
        },
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: '0000 0000 0000 0000',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }

  Widget _buildExpiryField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _expiryError != null ? AppColors.error : AppColors.border,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: TextField(
        controller: _expiryController,
        keyboardType: TextInputType.number,
        onChanged: (value) {
          final formatted = _formatExpiry(value);
          _expiryController.value = _expiryController.value.copyWith(
            text: formatted,
            selection: TextSelection.fromPosition(
              TextPosition(offset: formatted.length),
            ),
          );
          if (_expiryError != null) {
            setState(() {
              _expiryError = Validators.validateExpiry(formatted);
            });
          }
          setState(() {});
        },
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'MM/YY',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }

  Widget _buildCVCField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _cvcError != null ? AppColors.error : AppColors.border,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: TextField(
        controller: _cvcController,
        keyboardType: TextInputType.number,
        obscureText: true,
        maxLength: 4,
        onChanged: (value) {
          if (_cvcError != null) {
            setState(() {
              _cvcError = Validators.validateCVC(value);
            });
          }
          setState(() {});
        },
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: '123',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          counterText: '',
        ),
      ),
    );
  }

  Widget _buildCardholderNameField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _cardholderError != null ? AppColors.error : AppColors.border,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: TextField(
        controller: _cardholderNameController,
        onChanged: (value) {
          if (_cardholderError != null) {
            setState(() {
              _cardholderError = Validators.validateRequired(value);
            });
          }
          setState(() {});
        },
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Full name on card',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }

  String _getCardType(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (digits.isEmpty) return 'Card';
    if (digits.startsWith('4')) return 'Visa';
    if (digits.startsWith('5')) return 'Mastercard';
    if (digits.startsWith('3')) return 'Amex';
    return 'Card';
  }
}
