import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Date picker widget for selecting booking date
class DatePicker extends StatefulWidget {
  /// Label text displayed above the picker
  final String label;

  /// Selected date in mm/dd/yyyy format
  final String selectedDate;

  /// Callback when date changes
  final ValueChanged<String> onChanged;

  const DatePicker({
    required this.label,
    required this.selectedDate,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.selectedDate);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _parseDate(widget.selectedDate) ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('MM/dd/yyyy').format(pickedDate);
      _dateController.text = formattedDate;
      widget.onChanged(formattedDate);
    }
  }

  DateTime? _parseDate(String dateString) {
    if (dateString.isEmpty) return null;
    try {
      return DateFormat('MM/dd/yyyy').parse(dateString);
    } catch (e) {
      return null;
    }
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
        _buildDateField(),
      ],
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: TextField(
          controller: _dateController,
          enabled: false,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'mm/dd/yyyy',
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: Icon(
                Icons.calendar_today,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
          ),
        ),
      ),
    );
  }
}

/// Time picker widget for selecting booking time
class TimePicker extends StatefulWidget {
  /// Label text displayed above the picker
  final String label;

  /// Selected time (e.g., "09:00 AM")
  final String selectedTime;

  /// Callback when time changes
  final ValueChanged<String> onChanged;

  const TimePicker({
    required this.label,
    required this.selectedTime,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  late int _selectedHour;
  late String _selectedPeriod;
  final List<String> _hours = List.generate(12, (i) => '${(i + 1).toString().padLeft(2, '0')}');
  final List<String> _periods = ['AM', 'PM'];

  @override
  void initState() {
    super.initState();
    _parseTime();
  }

  void _parseTime() {
    try {
      final parts = widget.selectedTime.split(' ');
      final timeParts = parts[0].split(':');
      _selectedHour = int.parse(timeParts[0]);
      _selectedPeriod = parts[1];
    } catch (e) {
      _selectedHour = 9;
      _selectedPeriod = 'AM';
    }
  }

  String _getFormattedTime() {
    return '${_selectedHour.toString().padLeft(2, '0')}:00 $_selectedPeriod';
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
        _buildTimeSelector(),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<int>(
              value: _selectedHour,
              isExpanded: true,
              underline: const SizedBox(),
              items: _hours.map((hour) {
                return DropdownMenuItem(
                  value: int.parse(hour),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Text(
                      '$hour:00',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedHour = newValue;
                  });
                  widget.onChanged(_getFormattedTime());
                }
              },
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              icon: const SizedBox.shrink(),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          ),
          DropdownButton<String>(
            value: _selectedPeriod,
            underline: const SizedBox(),
            items: _periods.map((period) {
              return DropdownMenuItem(
                value: period,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Text(
                    period,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedPeriod = newValue;
                });
                widget.onChanged(_getFormattedTime());
              }
            },
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            icon: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
