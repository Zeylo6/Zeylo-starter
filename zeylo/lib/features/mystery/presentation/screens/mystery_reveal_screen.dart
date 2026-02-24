import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/mystery_provider.dart';

/// Mystery reveal screen
///
/// Based on Figma "reveal"
/// Displays the revealed mystery experience with:
/// - Gift box icon
/// - Experience details (image, title, description)
/// - Date, time, location, and duration info
/// - Accept/Decline buttons
class MysteryRevealScreen extends ConsumerStatefulWidget {
  /// Mystery ID that was revealed
  final String mysteryId;

  /// Experience details (title, description, image, etc)
  final String experienceTitle;
  final String experienceImage;
  final String experienceDescription;
  final String dateTime;
  final String duration;
  final String location;

  const MysteryRevealScreen({
    required this.mysteryId,
    required this.experienceTitle,
    required this.experienceImage,
    required this.experienceDescription,
    required this.dateTime,
    required this.duration,
    required this.location,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<MysteryRevealScreen> createState() =>
      _MysteryRevealScreenState();
}

class _MysteryRevealScreenState extends ConsumerState<MysteryRevealScreen> {
  @override
  Widget build(BuildContext context) {
    final revealState = ref.watch(revealMysteryProvider);

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
              // Gift box icon
              Center(
                child: Container(
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
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              Center(
                child: Text(
                  'Mystery Experience Revealed!',
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Subtitle
              Center(
                child: Text(
                  'Your surprise is ready',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Experience card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppRadius.lg),
                        topRight: Radius.circular(AppRadius.lg),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: widget.experienceImage,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            _buildImagePlaceholder(),
                        errorWidget: (context, url, error) =>
                            _buildImagePlaceholder(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            widget.experienceTitle,
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Description
                          Text(
                            widget.experienceDescription,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Info rows
                          _buildInfoRow('Date & Time', widget.dateTime),
                          const SizedBox(height: AppSpacing.md),
                          _buildInfoRow('Duration', widget.duration),
                          const SizedBox(height: AppSpacing.md),
                          _buildInfoRowWithLink('Location', widget.location),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Accept/Decline buttons
              Row(
                children: [
                  // Accept button (green)
                  Expanded(
                    child: ZeyloButton(
                      label: revealState.isLoading ? 'Processing...' : 'Accept',
                      variant: ButtonVariant.filled,
                      isLoading: revealState.isLoading,
                      isDisabled: revealState.isLoading,
                      onPressed: revealState.isLoading
                          ? null
                          : () async {
                              final success = await ref
                                  .read(revealMysteryProvider.notifier)
                                  .acceptMystery(widget.mysteryId);
                              if (success && mounted) {
                                Navigator.of(context).pop(true);
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Decline button (outlined)
                  Expanded(
                    child: ZeyloButton(
                      label: 'Decline',
                      variant: ButtonVariant.outlined,
                      isDisabled: revealState.isLoading,
                      onPressed: revealState.isLoading
                          ? null
                          : () async {
                              final success = await ref
                                  .read(revealMysteryProvider.notifier)
                                  .declineMystery(widget.mysteryId);
                              if (success && mounted) {
                                Navigator.of(context).pop(false);
                              }
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Footer note
              Text(
                'Cancellations within 24 hours are non refundable',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textHint,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      color: AppColors.surface,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.textHint,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowWithLink(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () {
            // TODO: Implement map view
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('View on Map')),
            );
          },
          child: Text(
            'View on Map',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
