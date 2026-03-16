import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/mood_entity.dart';
import '../providers/mood_provider.dart';
import '../widgets/mood_card.dart';

/// Mood selector screen
///
/// Based on Figma "iPhone 16 Pro Max - 17"
/// Allows users to select their current mood or type a custom one.
/// Displays a 2x3 grid of predefined moods:
/// - Happy
/// - Relaxed
/// - Adventurous
/// - Social
/// - Creative
/// - Energetic
class MoodSelectorScreen extends ConsumerStatefulWidget {
  /// Callback when mood is selected and confirmed
  final Function(String mood)? onMoodSelected;

  const MoodSelectorScreen({
    this.onMoodSelected,
    super.key,
  });

  @override
  ConsumerState<MoodSelectorScreen> createState() =>
      _MoodSelectorScreenState();
}

class _MoodSelectorScreenState extends ConsumerState<MoodSelectorScreen> {
  late TextEditingController _customMoodController;

  @override
  void initState() {
    super.initState();
    _customMoodController = TextEditingController();
  }

  @override
  void dispose() {
    _customMoodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moodState = ref.watch(moodProvider);

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
              // Title
              Text(
                'How are you feeling?',
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Subtitle
              Text(
                'Select your current mood or type it below',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Mood grid (2x3)
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: PredefinedMood.values.map((mood) {
                  final isSelected = moodState.selectedMood == mood.label;
                  return MoodCard(
                    icon: _getMoodIcon(mood),
                    label: mood.label,
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(moodProvider.notifier)
                          .selectPredefinedMood(mood.label);
                      _customMoodController.clear();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Divider with "Or" text
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppColors.border,
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      'Or',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColors.border,
                      height: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Custom mood text field
              Text(
                'Type Your Mood',
                style: AppTypography.labelMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: TextField(
                  controller: _customMoodController,
                  decoration: InputDecoration(
                    hintText: 'Describe your mood...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textHint,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Icon(
                        Icons.edit_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      ref.read(moodProvider.notifier)
                          .setCustomMood(value);
                    }
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: moodState.selectedMood != null &&
                          moodState.selectedMood!.isNotEmpty
                      ? () {
                          widget.onMoodSelected
                              ?.call(moodState.selectedMood!);
                          Navigator.of(context)
                              .pushNamed('/mood-describe');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.primary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textInverse,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMoodIcon(PredefinedMood mood) {
    switch (mood) {
      case PredefinedMood.happy:
        return Icons.sentiment_satisfied;
      case PredefinedMood.relaxed:
        return Icons.sentiment_satisfied_alt;
      case PredefinedMood.adventurous:
        return Icons.hiking;
      case PredefinedMood.social:
        return Icons.public;
      case PredefinedMood.creative:
        return Icons.palette;
      case PredefinedMood.energetic:
        return Icons.directions_run;
    }
  }
}
