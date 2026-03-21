import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

class CreateMysteryScreen extends ConsumerStatefulWidget {
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
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  late TextEditingController _budgetMinController;
  late TextEditingController _budgetMaxController;

  @override
  void initState() {
    super.initState();
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
              // Icon
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

              Center(
                child: Text(
                  'Create Your Mystery',
                  style: AppTypography.displayLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

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

              // Location
              ZeyloTextField(
                label: 'Location',
                hint: 'Where do you want to explore?',
                controller: _locationController,
                prefixWidget: const Icon(Icons.location_on_outlined,
                    color: AppColors.textSecondary, size: 20),
                onChanged: (value) => formNotifier.setLocation(value),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Date + Time
              Row(
                children: [
                  Expanded(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Time', style: AppTypography.labelMedium),
                        const SizedBox(height: AppSpacing.sm),
                        _buildTimeDropdown(formNotifier, formState),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Budget
              Row(
                children: [
                  Expanded(
                    child: ZeyloTextField(
                      label: 'Budget Min',
                      hint: 'Rs. 0',
                      controller: _budgetMinController,
                      prefixWidget: const Padding(
                        padding: EdgeInsets.only(left: 12, top: 12),
                        child: Text('Rs. ',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold)),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        formNotifier.setBudgetMin(
                            double.tryParse(value) ?? 0);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ZeyloTextField(
                      label: 'Budget Max',
                      hint: 'Rs. 50,000',
                      controller: _budgetMaxController,
                      prefixWidget: const Padding(
                        padding: EdgeInsets.only(left: 12, top: 12),
                        child: Text('Rs. ',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold)),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        formNotifier.setBudgetMax(
                            double.tryParse(value) ?? 50000);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Experience Type
              MysteryTypeSelector(
                selectedType: formState.experienceType,
                onTypeSelected: (type) =>
                    formNotifier.setExperienceType(type),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Error
              if (formState.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text(
                    formState.error!,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.error),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Continue button watches provider for loading state
              Consumer(
                builder: (context, ref, child) {
                  final currentState = ref.watch(mysteryFormProvider(widget.userId));
                  
                  return ZeyloButton(
                    label: currentState.isLoading ? 'Matching...' : 'Find My Mystery',
                    isLoading: currentState.isLoading,
                    isDisabled: _locationController.text.isEmpty ||
                        _dateController.text.isEmpty || currentState.isLoading,
                    onPressed: (_locationController.text.isEmpty ||
                            _dateController.text.isEmpty || currentState.isLoading)
                        ? null
                        : () async {
                            FocusScope.of(context).unfocus();
                            
                            await ref.read(mysteryFormProvider(widget.userId).notifier).submitForm();
                            
                            // Read updated state after submit
                            final updated = ref.read(mysteryFormProvider(widget.userId));
                            
                            if (!mounted) return;
                            
                            if (updated.isSuccess) {
                              _showSuccessDialog(context, updated);
                            } else if (updated.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${updated.error}'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                  );
                }
              ),
              const SizedBox(height: AppSpacing.xl),

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
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(time.label, style: AppTypography.bodyMedium),
            ),
          );
        }).toList(),
        onChanged: (time) {
          if (time != null) formNotifier.setTime(time);
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
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      final dateStr =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}';
      _dateController.text = dateStr;
      formNotifier.setDate(dateStr);
    }
  }

  void _showSuccessDialog(
      BuildContext context, MysteryFormState formState) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gift icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text(
                'Mystery Booked! 🎁',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),

              Text(
                'Your surprise experience has been matched and booked! It will appear in your Upcoming bookings.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Teaser
              if (formState.teaserDescription != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      if (formState.vibe != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            formState.vibe!,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      Text(
                        formState.teaserDescription!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              if (formState.preparationNotes != null) ...[
                Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        formState.preparationNotes!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              Text(
                'Details will be revealed 48 hours before your experience.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),

              ZeyloButton(
                label: 'View My Bookings',
                onPressed: () {
                  // Close dialog
                  Navigator.of(dialogCtx).pop();
                  // Navigate to seeker dashboard — stream will show the new booking
                  context.replace('/seeker-dashboard');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}