import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/chain_entity.dart';
import '../providers/chain_provider.dart';
import '../widgets/interest_chip_list.dart';
import '../widgets/time_selector.dart';

/// Create chain (mini trip) screen
///
/// Based on Figma "chain"
/// Allows users to create a new chain with:
/// - Destination city selection
/// - Date selection
/// - Total time available preference
/// - Interest selection
/// - Suggested chain preview
class CreateChainScreen extends ConsumerStatefulWidget {
  /// User ID creating the chain
  final String userId;

  const CreateChainScreen({
    required this.userId,
    super.key,
  });

  @override
  ConsumerState<CreateChainScreen> createState() =>
      _CreateChainScreenState();
}

class _CreateChainScreenState extends ConsumerState<CreateChainScreen> {
  late TextEditingController _destinationController;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _destinationController = TextEditingController();
    _dateController = TextEditingController();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(chainFormProvider(widget.userId));
    final formNotifier = ref.read(chainFormProvider(widget.userId).notifier);

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
              // Chain link icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.link,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              Center(
                child: Text(
                  'Create Your Mini Trip Today!',
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Subtitle
              Center(
                child: Text(
                  'Connect multiple experiences for the perfect day',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Destination City field
              ZeyloTextField(
                label: 'Destination City',
                hint: 'Where do you want to explore?',
                controller: _destinationController,
                prefixWidget: const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 20),
                onChanged: (value) => formNotifier.setDestinationCity(value),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Date field
              ZeyloTextField(
                label: 'Date',
                hint: 'mm/dd/yyyy',
                controller: _dateController,
                prefixWidget: const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
                onChanged: (value) => formNotifier.setDate(value),
                readOnly: true,
                onTap: () => _selectDate(context, formNotifier),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Time selector
              TimeSelector(
                selectedDuration: formState.totalTime,
                onDurationSelected: (duration) =>
                    formNotifier.setTotalTime(duration),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Interest chip list
              InterestChipList(
                selectedInterests: formState.selectedInterests,
                onInterestToggled: (interest) =>
                    formNotifier.toggleInterest(interest),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Suggested chain section
              _buildSuggestedChainSection(),
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
                        if (formState.error == null && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Chain created successfully!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      },
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedChainSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested Chain: San Francisco Food & Culture',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Suggested experiences
          _buildSuggestedExperience(
            1,
            'Morning Coffee & Pastry Tour',
            '9:00 AM - 11:00 AM',
            '2h',
            '\$35',
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSuggestedExperience(
            2,
            'Chinatown Cultural Walk',
            '11:30 AM - 1:30 PM',
            '2h',
            '\$40',
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedExperience(
    int position,
    String title,
    String timeRange,
    String duration,
    String price,
  ) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$position',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textInverse,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                timeRange,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              duration,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              price,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    ChainFormNotifier formNotifier,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      final dateStr = '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.year}';
      _dateController.text = dateStr;
      formNotifier.setDate(dateStr);
    }
  }
}
