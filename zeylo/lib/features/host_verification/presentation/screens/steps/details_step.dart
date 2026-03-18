import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../providers/host_verification_flow_provider.dart';
import 'package:intl/intl.dart';

class HostVerificationDetailsScreen extends ConsumerStatefulWidget {
  const HostVerificationDetailsScreen({super.key});

  @override
  ConsumerState<HostVerificationDetailsScreen> createState() => _HostVerificationDetailsScreenState();
}

class _HostVerificationDetailsScreenState extends ConsumerState<HostVerificationDetailsScreen> {
  late TextEditingController _nameController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final state = ref.read(hostVerificationFlowProvider);
    _nameController = TextEditingController(text: state.fullName);
    _selectedDate = state.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Must be at least 18
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Personal Details'),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(hostVerificationFlowProvider.notifier).previousStep();
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Tell us about yourself',
                    style: AppTypography.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Please ensure these details match your government ID exactly.',
                    style: AppTypography.bodyMediumSecondary,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  
                  ZeyloTextField(
                    label: 'Full Legal Name',
                    hint: 'John Doe',
                    controller: _nameController,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  Text(
                    'Date of Birth',
                    style: AppTypography.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate == null
                                ? 'Select your Date of Birth'
                                : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                            style: _selectedDate == null 
                                ? AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)
                                : AppTypography.bodyMedium,
                          ),
                          const Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 20),
                        ],
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  ZeyloButton(
                    label: 'Continue',
                    onPressed: (_nameController.text.isNotEmpty && _selectedDate != null)
                        ? () {
                            ref.read(hostVerificationFlowProvider.notifier)
                                .updatePersonalDetails(_nameController.text, _selectedDate!);
                            ref.read(hostVerificationFlowProvider.notifier).nextStep();
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
