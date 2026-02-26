import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// PhoneInputField - Specialized text field for phone number input
///
/// Features:
/// - Sri Lankan flag prefix (🇱🇰) with country code
/// - Phone number input with formatting
/// - Same styling as ZeyloTextField
/// - Placeholder: "07X XXX XXXX"
/// - Optional validation
///
/// Example:
/// ```dart
/// PhoneInputField(
///   label: 'Phone Number',
///   controller: phoneController,
///   onChanged: (value) => print('Phone: $value'),
///   errorText: 'Invalid phone number',
/// )
/// ```
class PhoneInputField extends StatefulWidget {
  /// Label text displayed above the field
  final String label;

  /// The text editing controller
  final TextEditingController controller;

  /// Validation error text
  final String? errorText;

  /// On changed callback
  final ValueChanged<String>? onChanged;

  /// On submit callback
  final VoidCallback? onSubmitted;

  /// Whether the field is enabled
  final bool enabled;

  /// Border radius
  final double borderRadius;

  /// Country code (default: +94 for Sri Lanka)
  final String countryCode;

  /// Country flag emoji
  final String countryFlag;

  const PhoneInputField({
    required this.label,
    required this.controller,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.borderRadius = AppRadius.md,
    this.countryCode = '+94',
    this.countryFlag = '🇱🇰',
    super.key,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String value) {
    // Remove all non-digits
    String digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    // Remove leading 94 if present (country code)
    if (digitsOnly.startsWith('94')) {
      digitsOnly = digitsOnly.substring(2);
    }

    // Format as 07X XXX XXXX
    if (digitsOnly.isEmpty) {
      return '';
    }

    if (digitsOnly.length <= 2) {
      return digitsOnly;
    }

    if (digitsOnly.length <= 5) {
      return '${digitsOnly.substring(0, 2)} ${digitsOnly.substring(2)}';
    }

    return '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6)}';
  }

  String _getUnformattedPhoneNumber(String formatted) {
    // Remove spaces
    String unformatted = formatted.replaceAll(' ', '');
    // Add country code if not present
    if (!unformatted.startsWith('94') && unformatted.isNotEmpty) {
      unformatted = '94$unformatted';
    }
    return unformatted;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: AppTypography.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        // Phone input field
        _buildPhoneField(),
        // Error text
        if (widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.errorText!,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: widget.errorText != null
              ? AppColors.error
              : _focusNode.hasFocus
                  ? AppColors.primary
                  : AppColors.border,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        enabled: widget.enabled,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        onChanged: (value) {
          // Format the input
          final formatted = _formatPhoneNumber(value);
          final unformatted = _getUnformattedPhoneNumber(formatted);

          // Update controller with formatted value
          widget.controller.value = widget.controller.value.copyWith(
            text: formatted,
            selection: TextSelection.fromPosition(
              TextPosition(offset: formatted.length),
            ),
          );

          // Callback with unformatted value
          widget.onChanged?.call(unformatted);
        },
        onSubmitted: (_) => widget.onSubmitted?.call(),
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: '07X XXX XXXX',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.lg),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.countryFlag,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  widget.countryCode,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: AppSpacing.sm),
                  width: 1,
                  height: 24,
                  color: AppColors.border,
                ),
              ],
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
          counterText: '',
        ),
      ),
    );
  }
}
