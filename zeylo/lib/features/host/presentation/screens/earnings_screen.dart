import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/host_provider.dart';
import '../widgets/earnings_stat_card.dart';
import '../widgets/payout_tile.dart';

/// Host earnings screen
/// Adapted for responsive Web layout. Constrained to fixed max-width on Desktop to avoid wide stretching.
class EarningsScreen extends ConsumerWidget {
  final String hostId;

  const EarningsScreen({
    required this.hostId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earningsAsync = ref.watch(hostEarningsProvider(hostId));
    final trendAsync = ref.watch(earningsTrendProvider(hostId));

    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: isDesktop ? null : IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Earnings Dashboard',
          style: AppTypography.titleLarge.copyWith(
             color: AppColors.textPrimary,
             fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: earningsAsync.when(
        data: (earnings) => trendAsync.when(
          data: (trend) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: _buildContent(context, earnings, trend, isDesktop),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    dynamic earnings,
    double trend,
    bool isDesktop,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
         horizontal: AppSpacing.md, 
         vertical: isDesktop ? AppSpacing.xl : AppSpacing.md
      ),
      child: Container(
        padding: EdgeInsets.all(isDesktop ? AppSpacing.xl : AppSpacing.sm),
        decoration: isDesktop ? BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
          boxShadow: [
             BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
             )
          ]
        ) : null,
        child: Column(
          children: [
            // Month dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'This Month',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'October',
                        style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Total balance section
            Column(
              children: [
                Text(
                  'Total Balance',
                  style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Rs. ${earnings.totalBalance.toStringAsFixed(0)}',
                  style: AppTypography.headlineLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 48,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Trend indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: (trend >= 0 ? AppColors.success : AppColors.error).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trend >= 0 ? Icons.trending_up : Icons.trending_down,
                        color: trend >= 0 ? AppColors.success : AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${trend >= 0 ? '+' : ''}${trend.toStringAsFixed(1)}% vs last month',
                        style: AppTypography.labelMedium.copyWith(
                          color: trend >= 0 ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Stats cards row
            Row(
              children: [
                Expanded(
                  child: EarningsStatCard(
                    label: 'Gross Income',
                    value: 'Rs. ${earnings.grossIncome.toStringAsFixed(0)}',
                    backgroundColor: AppColors.success.withOpacity(0.1),
                    textColor: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: EarningsStatCard(
                    label: 'Platform Fee (10%)',
                    value: '-Rs. ${earnings.platformFee.toStringAsFixed(0)}',
                    backgroundColor: AppColors.error.withOpacity(0.1),
                    textColor: AppColors.error,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Recent payouts section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                   children: [
                      const Icon(Icons.history, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                         'Recent Payouts',
                         style: AppTypography.titleMedium.copyWith(
                           color: AppColors.textPrimary,
                           fontWeight: FontWeight.bold,
                         ),
                      ),
                   ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Payouts list
                if (earnings.payouts.isEmpty)
                   Center(
                      child: Padding(
                         padding: const EdgeInsets.all(AppSpacing.xl),
                         child: Text("No payouts processed yet.", style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
                      )
                   )
                else
                   ...earnings.payouts.asMap().entries.map((entry) {
                     final payout = entry.value;
                     return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        decoration: BoxDecoration(
                           color: AppColors.surfaceContainerLow,
                           borderRadius: BorderRadius.circular(AppRadius.md),
                           border: Border.all(color: AppColors.border.withOpacity(0.5)),
                        ),
                        child: PayoutTile(
                          title: 'Weekly Payout',
                          date: _formatDate(payout.date),
                          amount: payout.amount,
                          isPositive: true,
                        ),
                     );
                   }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
  }

  String _getMonthName(int month) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
