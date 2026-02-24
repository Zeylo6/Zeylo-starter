import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Guest selector dropdown widget
/// Allows selection of number of guests (1-10)
class GuestSelector extends StatefulWidget {
  /// Label text displayed above the selector
  final String label;

  /// Current number of guests selected
  final int selectedGuests;

  /// Callback when guest count changes
  final ValueChanged<int> onChanged;

  /// Minimum number of guests allowed
  final int minGuests;

  /// Maximum number of guests allowed
  final int maxGuests;

  const GuestSelector({
    required this.label,
    required this.selectedGuests,
    required this.onChanged,
    this.minGuests = 1,
    this.maxGuests = 10,
    Key? key,
  }) : super(key: key);

  @override
  State<GuestSelector> createState() => _GuestSelectorState();
}

class _GuestSelectorState extends State<GuestSelector> {
  late int _selectedGuests;

  @override
  void initState() {
    super.initState();
    _selectedGuests = widget.selectedGuests;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildSelector(),
      ],
    );
  }

  Widget _buildSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: DropdownButton<int>(
        value: _selectedGuests,
        isExpanded: true,
        underline: const SizedBox(),
        items: List.generate(
          widget.maxGuests - widget.minGuests + 1,
          (index) {
            final guests = widget.minGuests + index;
            return DropdownMenuItem(
              value: guests,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Text(
                  guests == 1 ? '$guests Guest' : '$guests Guests',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            );
          },
        ),
        onChanged: (int? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedGuests = newValue;
            });
            widget.onChanged(newValue);
          }
        },
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        icon: Icon(
          Icons.expand_more,
          color: AppColors.primary,
          size: 24,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    );
  }
}
