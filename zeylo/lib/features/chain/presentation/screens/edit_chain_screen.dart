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
import '../widgets/chain_experience_card.dart';

/// Edit chain (mini trip) screen
///
/// Based on Figma "edit chain"
/// Allows users to:
/// - Edit chain name
/// - Edit chain description
/// - Add/remove/edit experiences in the chain
/// - View total chain price
class EditChainScreen extends ConsumerStatefulWidget {
  /// Chain to edit
  final ChainEntity chain;

  const EditChainScreen({
    required this.chain,
    super.key,
  });

  @override
  ConsumerState<EditChainScreen> createState() => _EditChainScreenState();
}

class _EditChainScreenState extends ConsumerState<EditChainScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.chain.name);
    _descriptionController =
        TextEditingController(text: widget.chain.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(editChainProvider);

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
              // Chain name field
              ZeyloTextField(
                label: 'Chain Name',
                hint: 'Enter chain name',
                controller: _nameController,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Description field
              ZeyloTextField(
                label: 'Description',
                hint: 'Describe your chain...',
                controller: _descriptionController,
                maxLines: 3,
                suffixWidget: IconButton(
                  icon: editState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary))
                      : const Icon(Icons.auto_awesome,
                          color: AppColors.primary, size: 20),
                  tooltip: 'Enhance with AI',
                  onPressed: editState.isLoading
                      ? null
                      : () async {
                          if (_descriptionController.text.trim().isEmpty) return;
                          
                          // Show loading by using the state
                          ref.read(editChainProvider.notifier).setLoading(true);
                              
                          try {
                            final aiService = ref.read(aiServiceProvider);
                            final enhanced = await aiService.enhanceText(
                                _descriptionController.text, 'chain_description');
                            
                            if (mounted) {
                              setState(() {
                                _descriptionController.text = enhanced;
                              });
                            }
                          } catch (e) {
                             if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('AI Enhancement failed: $e')),
                              );
                            }
                          } finally {
                            if (mounted) {
                              ref.read(editChainProvider.notifier).setLoading(false);
                            }
                          }
                        },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Experiences header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Experiences in Chain',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Implement add experience flow
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add experience')),
                      );
                    },
                    child: Text(
                      '+ Add',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Experience cards
              ...List.generate(
                widget.chain.experiences.length,
                (index) {
                  final experience = widget.chain.experiences[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: ChainExperienceCard(
                      experience: experience,
                      position: index + 1,
                      onEdit: () {
                        // TODO: Implement edit experience
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Edit ${experience.title}'),
                          ),
                        );
                      },
                      onRemove: () {
                        // TODO: Remove experience
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Remove ${experience.title}'),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Total price field
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Chain Price',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '\$${widget.chain.totalPrice.toStringAsFixed(0)}',
                      style: AppTypography.headlineLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Error message
              if (editState.error != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text(
                    editState.error!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              if (editState.error != null)
                const SizedBox(height: AppSpacing.lg),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ZeyloButton(
                      label: editState.isLoading ? 'Saving...' : 'Save Changes',
                      variant: ButtonVariant.filled,
                      isLoading: editState.isLoading,
                      isDisabled: editState.isLoading,
                      onPressed: editState.isLoading
                          ? null
                          : () async {
                              final updated = widget.chain.copyWith(
                                name: _nameController.text,
                                description: _descriptionController.text,
                              );
                              final success = await ref
                                  .read(editChainProvider.notifier)
                                  .updateChain(updated);
                              if (success && mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  ZeyloButton(
                    label: 'Publish',
                    variant: ButtonVariant.outlined,
                    isDisabled: editState.isLoading,
                    onPressed: editState.isLoading
                        ? null
                        : () async {
                            final success = await ref
                                .read(editChainProvider.notifier)
                                .publishChain(widget.chain.id);
                            if (success && mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
