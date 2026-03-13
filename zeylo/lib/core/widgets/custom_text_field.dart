import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// ZeyloTextField widget with label, hint, and validation support
///
/// Features:
/// - Label text displayed above the field
/// - Hint text inside the field
/// - Rounded border (radius 12) with light border color
/// - Purple focus border
/// - Optional prefix widget (e.g., country flag for phone input)
/// - Optional suffix widget (e.g., password visibility toggle)
/// - Obscure text toggle for passwords
/// - Validation error text
/// - TextEditingController, keyboardType, and textInputAction support
///
/// Example:
/// ```dart
/// ZeyloTextField(
///   label: 'Email Address',
///   hint: 'Enter your email',
///   controller: emailController,
///   keyboardType: TextInputType.emailAddress,
///   errorText: 'Invalid email',
/// )
/// ```
class ZeyloTextField extends StatefulWidget {
  /// Label text displayed above the field
  final String label;

  /// Hint text displayed inside the field when empty
  final String hint;

  /// The text editing controller
  final TextEditingController controller;

  /// Keyboard type
  final TextInputType keyboardType;

  /// Text input action
  final TextInputAction textInputAction;

  /// Optional prefix widget (left side of input)
  final Widget? prefixWidget;

  /// Optional suffix widget (right side of input)
  final Widget? suffixWidget;

  /// Whether to obscure text (for passwords)
  final bool obscureText;

  /// Validation error text
  final String? errorText;

  /// On changed callback
  final ValueChanged<String>? onChanged;

  /// On submit callback
  final VoidCallback? onSubmitted;

  /// Maximum number of lines
  final int maxLines;

  /// Minimum number of lines
  final int minLines;

  /// Max length of input
  final int? maxLength;

  /// Whether to show counter
  final bool showCounter;

  /// Whether the field is enabled
  final bool enabled;

  /// Whether the field is read-only (e.g., for date pickers)
  final bool readOnly;

  /// Callback when the field is tapped (useful with readOnly for date pickers)
  final VoidCallback? onTap;

  /// Border radius
  final double borderRadius;

  const ZeyloTextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.prefixWidget,
    this.suffixWidget,
    this.obscureText = false,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.showCounter = false,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.borderRadius = AppRadius.md,
    this.prefixIcon,
    this.child,
    super.key,
  });

  final Widget? prefixIcon;
  final Widget? child;

  @override
  State<ZeyloTextField> createState() => _ZeyloTextFieldState();
}

class _ZeyloTextFieldState extends State<ZeyloTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
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
        // Text Field
        _buildTextField(),
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

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        color: widget.enabled ? AppColors.surfaceContainerHigh : AppColors.surfaceContainerLow,
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
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        obscureText: _obscureText,
        maxLines: widget.obscureText ? 1 : widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        onSubmitted: (_) => widget.onSubmitted?.call(),
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          prefixIcon: widget.prefixIcon ?? (widget.prefixWidget != null
              ? Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.lg),
                  child: widget.prefixWidget,
                )
              : null),
          prefixIconConstraints: (widget.prefixIcon != null || widget.prefixWidget != null)
              ? const BoxConstraints(minHeight: 0, minWidth: 0)
              : null,
          suffixIcon: widget.child ?? _buildSuffixIcon(),
          suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
          counterText: widget.showCounter ? null : '',
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixWidget != null) {
      return Padding(
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: widget.suffixWidget,
      );
    }

    if (widget.obscureText) {
      return Padding(
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      );
    }

    return null;
  }
}
