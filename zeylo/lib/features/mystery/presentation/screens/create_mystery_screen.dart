import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/mystery_entity.dart';
import '../providers/mystery_provider.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/mystery_type_selector.dart';

/// Create mystery booking screen
///
/// Based on Figma "mystery booking" / "iPhone 16 Pro Max - 8"
/// Allows users to create a new mystery experience booking with:
/// - Location selection
/// - Date and time preferences
/// - Budget range
/// - Experience type selection
/// - How it works explanation
class CreateMysteryScreen extends ConsumerStatefulWidget {
  /// User ID creating the mystery
  final String userId;

  const CreateMysteryScreen({
    required this.userId,
    super.key,
  });

  @override
  ConsumerState<CreateMysteryScreen> createState() =>
      _CreateMysteryScreenState();
}

class _CreateMysteryScreenState extends ConsumerState<CreateMysteryScreen> {
  late TextEditingController _locationController;
  late TextEditingController _dateController;
  late TextEditingController _budgetMinController;
  late TextEditingController _budgetMaxController;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController();
    _dateController = TextEditingController();
    _budgetMinController = TextEditingController();
    _budgetMaxController = TextEditingController();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _dateController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(mysteryFormProvider(widget.userId));
    final formNotifier = ref.read(mysteryFormProvider(widget.userId).notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Purple question mark icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              Center(
                child: Text(
                  'Create Your Mystery',
                  style: AppTypography.displayLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Subtitle
              Center(
                child: Text(
                  'Let us surprise you with an amazing experience',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Location field
              ZeyloTextField(
                label: 'Location',
                hint: 'Where do you want to explore?',
                controller: _locationController,
                prefixWidget: const Icon(Icons.location_on_outlined,
                    color: AppColors.textSecondary, size: 20),
                onChanged: (value) => formNotifier.setLocation(value),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Date and Time row
              Row(
                children: [
                  // Date field
                  Expanded(
                    flex: 1,
                    child: ZeyloTextField(
                      label: 'Date',
                      hint: 'dd/mm',
                      controller: _dateController,
                      prefixWidget: const Icon(Icons.calendar_today_outlined,
                          color: AppColors.textSecondary, size: 20),
                      onChanged: (value) => formNotifier.setDate(value),
                      readOnly: true,
                      onTap: () => _selectDate(context, formNotifier),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Time dropdown
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time',
                          style: AppTypography.labelMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _buildTimeDropdown(formNotifier, formState),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Budget Range
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: ZeyloTextField(
                      label: 'Budget Min',
                      hint: 'Rs. 0',
                      controller: _budgetMinController,
                      prefixWidget: const Padding(
                        padding: EdgeInsets.only(left: 12, top: 12),
                        child: Text('Rs. ', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final val = double.tryParse(value) ?? 0;
                        formNotifier.setBudgetMin(val);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 1,
                    child: ZeyloTextField(
                      label: 'Budget Max',
                      hint: 'Rs. 50,000',
                      controller: _budgetMaxController,
                      prefixWidget: const Padding(
                        padding: EdgeInsets.only(left: 12, top: 12),
                        child: Text('Rs. ', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final val = double.tryParse(value) ?? 500;
                        formNotifier.setBudgetMax(val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Experience Type Selector
              MysteryTypeSelector(
                selectedType: formState.experienceType,
                onTypeSelected: (type) => formNotifier.setExperienceType(type),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Error message
              if (formState.error != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text(
                    formState.error!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              if (formState.error != null)
                const SizedBox(height: AppSpacing.lg),

              // Create button
              ZeyloButton(
                label: formState.isLoading ? 'Creating...' : 'Create',
                isLoading: formState.isLoading,
                isDisabled: formState.isLoading,
                onPressed: formState.isLoading
                    ? null
                    : () async {
                        await formNotifier.submitForm();
                        // Re-read state after async operation to check for errors
                        final updatedState =
                            ref.read(mysteryFormProvider(widget.userId));
                        if (updatedState.error == null && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mystery created successfully!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      },
              ),
              const SizedBox(height: AppSpacing.xl),

              // How it works section
              const HowItWorksSection(),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeDropdown(
    MysteryFormNotifier formNotifier,
    MysteryFormState formState,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: DropdownButton<MysteryTimeOfDay>(
        isExpanded: true,
        underline: const SizedBox(),
        value: formState.time,
        items: MysteryTimeOfDay.values.map((time) {
          return DropdownMenuItem(
            value: time,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                time.label,
                style: AppTypography.bodyMedium,
              ),
            ),
          );
        }).toList(),
        onChanged: (time) {
          if (time != null) {
            formNotifier.setTime(time);
          }
        },
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    MysteryFormNotifier formNotifier,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      final dateStr = '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}';
      _dateController.text = dateStr;
      formNotifier.setDate(dateStr);
    }
  }
}
