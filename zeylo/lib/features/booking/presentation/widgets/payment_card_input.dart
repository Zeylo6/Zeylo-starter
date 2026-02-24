import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_text_field.dart';

/// Payment card input widget for collecting credit card details
/// Includes card number, expiry, CVC, and cardholder name fields
class PaymentCardInput extends StatefulWidget {
  /// Callback when card number changes
  final ValueChanged<String> onCardNumberChanged;

  /// Callback when expiry changes
  final ValueChanged<String> onExpiryChanged;

  /// Callback when CVC changes
  final ValueChanged<String> onCVCChanged;

  /// Callback when cardholder name changes
  final ValueChanged<String> onCardholderNameChanged;

  /// Initial card number value
  final String cardNumber;

  /// Initial expiry value
  final String expiry;

  /// Initial CVC value
  final String cvc;

  /// Initial cardholder name value
  final String cardholderName;

  const PaymentCardInput({
    required this.onCardNumberChanged,
    required this.onExpiryChanged,
    required this.onCVCChanged,
    required this.onCardholderNameChanged,
    this.cardNumber = '',
    this.expiry = '',
    this.cvc = '',
    this.cardholderName = '',
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentCardInput> createState() => _PaymentCardInputState();
}

class _PaymentCardInputState extends State<PaymentCardInput> {
  late TextEditingController _cardNumberController;
  late TextEditingController _expiryController;
  late TextEditingController _cvcController;
  late TextEditingController _cardholderNameController;

  String _getCardBrand(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (digits.isEmpty) return '';

    if (digits.startsWith('4')) return 'Visa';
    if (digits.startsWith('5')) return 'Mastercard';
    if (digits.startsWith('3')) return 'Amex';

    return '';
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

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController(text: widget.cardNumber);
    _expiryController = TextEditingController(text: widget.expiry);
    _cvcController = TextEditingController(text: widget.cvc);
    _cardholderNameController = TextEditingController(text: widget.cardholderName);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _cardholderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: AppSpacing.lg),

        // Expiry and CVC in row
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
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Cardholder Name Field
        ZeyloTextField(
          label: 'Cardholder Name',
          hint: 'Full name on card',
          controller: _cardholderNameController,
          onChanged: widget.onCardholderNameChanged,
        ),
      ],
    );
  }

  Widget _buildCardNumberField() {
    final cardBrand = _getCardBrand(_cardNumberController.text);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: TextField(
        controller: _cardNumberController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(16),
        ],
        onChanged: (value) {
          final formatted = _formatCardNumber(value);
          _cardNumberController.value = _cardNumberController.value.copyWith(
            text: formatted,
            selection: TextSelection.fromPosition(
              TextPosition(offset: formatted.length),
            ),
          );
          widget.onCardNumberChanged(formatted);
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
          suffixIcon: cardBrand.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.lg),
                  child: _buildCardBrandIcon(cardBrand),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
        ),
      ),
    );
  }

  Widget _buildExpiryField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: TextField(
        controller: _expiryController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        onChanged: (value) {
          final formatted = _formatExpiry(value);
          _expiryController.value = _expiryController.value.copyWith(
            text: formatted,
            selection: TextSelection.fromPosition(
              TextPosition(offset: formatted.length),
            ),
          );
          widget.onExpiryChanged(formatted);
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
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: TextField(
        controller: _cvcController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        onChanged: widget.onCVCChanged,
        obscureText: true,
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
        ),
      ),
    );
  }

  Widget _buildCardBrandIcon(String brand) {
    final iconName = brand.toLowerCase();
    return Text(
      _getCardBrandEmoji(brand),
      style: const TextStyle(fontSize: 20),
    );
  }

  String _getCardBrandEmoji(String brand) {
    switch (brand) {
      case 'Visa':
        return '💳';
      case 'Mastercard':
        return '💳';
      case 'Amex':
        return '💳';
      default:
        return '';
    }
  }
}
