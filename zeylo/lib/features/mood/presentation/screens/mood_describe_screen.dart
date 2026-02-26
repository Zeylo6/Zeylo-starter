import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/mood_entity.dart';
import '../providers/mood_provider.dart';
import '../widgets/ai_enhancer_card.dart';

/// Mood describe screen
///
/// Based on Figma "iPhone 16 Pro Max - 18"
/// Allows users to describe their mood in detail and set preferences.
/// Features:
/// - Large text area for mood description
/// - AI prompt enhancer toggle
/// - Quick suggestion chips for preferences
/// - Find matches button
class MoodDescribeScreen extends ConsumerStatefulWidget {
  /// The mood selected in the previous screen
  final String? initialMood;

  const MoodDescribeScreen({
    this.initialMood,
    super.key,
  });

  @override
  ConsumerState<MoodDescribeScreen> createState() =>
      _MoodDescribeScreenState();
}

class _MoodDescribeScreenState extends ConsumerState<MoodDescribeScreen> {
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
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
                'Tell us how you\'re feeling',
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Description text area
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText:
                      'I\'m feeling excited and want to try something new...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(AppSpacing.lg),
                ),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 5,
                onChanged: (value) {
                  ref.read(moodProvider.notifier).setDescription(value);
                },
              ),
              const SizedBox(height: AppSpacing.sm),

              // Helper text
              Text(
                'Be as specific as you\'d like. The more details, the better matches!',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // AI Enhancer card
              AIEnhancerCard(
                isEnabled: moodState.useAIEnhancer,
                onToggle: () =>
                    ref.read(moodProvider.notifier).toggleAIEnhancer(),
                originalText: moodState.description,
                enhancedText: moodState.enhancedDescription,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Quick suggestions
              Text(
                'Quick suggestions',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _buildSuggestionChip(
                    'Add location preference',
                    Icons.location_on_outlined,
                    () {
                      ref.read(moodProvider.notifier)
                          .setLocationPreference('San Francisco');
                    },
                  ),
                  _buildSuggestionChip(
                    'Add budget range',
                    Icons.attach_money,
                    () {
                      ref.read(moodProvider.notifier)
                          .setBudgetPreference(25, 100);
                    },
                  ),
                  _buildSuggestionChip(
                    'Add time preference',
                    Icons.schedule,
                    () {
                      ref.read(moodProvider.notifier)
                          .setTimePreference(TimePreference.afternoon);
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Find Matches button
              ZeyloButton(
                label: moodState.isLoading ? 'Finding matches...' : 'Find Matches',
                isLoading: moodState.isLoading,
                isDisabled: moodState.isLoading ||
                    moodState.description.isEmpty,
                onPressed: moodState.isLoading ||
                        moodState.description.isEmpty
                    ? null
                    : () async {
                        await ref.read(moodProvider.notifier).findMatches();
                        if (mounted && !moodState.isLoading) {
                          Navigator.of(context)
                              .pushNamed('/mood-results');
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

  Widget _buildSuggestionChip(
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
