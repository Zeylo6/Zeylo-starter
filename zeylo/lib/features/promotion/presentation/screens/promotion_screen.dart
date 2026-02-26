import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/promotion_plan_card.dart';

/// Screen for event promotion plans
class PromotionScreen extends StatefulWidget {
  /// Experience/event ID to promote
  final String? eventId;

  const PromotionScreen({
    this.eventId,
    super.key,
  });

  @override
  State<PromotionScreen> createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  late PromotionPlan? selectedPlan;

  final basicPlan = PromotionPlan(
    name: 'Basic Plan',
    price: '\$29',
    features: [
      '7 days promotion',
      'Featured in local feed',
      'Basic analytics',
    ],
  );

  final premiumPlan = PromotionPlan(
    name: 'Premium Plan',
    price: '\$79',
    features: [
      '14 days promotion',
      'Top of feed placement',
      'Advanced analytics',
      'Community boost',
    ],
    isPopular: true,
  );

  @override
  void initState() {
    super.initState();
    selectedPlan = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Crown icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.workspace_premium,
                  color: AppColors.primary,
                  size: 48,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Title
              Text(
                'Event Promotion',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              // Subtitle
              Text(
                'Boost your event visibility',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              // Plans
              PromotionPlanCard(
                plan: basicPlan,
                isSelected: selectedPlan?.name == basicPlan.name,
                onTap: () {
                  setState(() => selectedPlan = basicPlan);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              PromotionPlanCard(
                plan: premiumPlan,
                isSelected: selectedPlan?.name == premiumPlan.name,
                onTap: () {
                  setState(() => selectedPlan = premiumPlan);
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              // Select button
              if (selectedPlan != null)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleSelectPlan,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Center(
                          child: Text(
                            'Select ${selectedPlan!.name}',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.textInverse,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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

  void _handleSelectPlan() {
    if (selectedPlan == null) return;

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm ${selectedPlan!.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to purchase:',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedPlan!.name,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    selectedPlan!.price,
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Proceed to payment?',
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _proceedToPayment();
            },
            child: Text(
              'Confirm',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToPayment() {
    // Handle payment navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Proceeding to payment for ${selectedPlan!.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
    // Navigate to payment screen
  }
}
