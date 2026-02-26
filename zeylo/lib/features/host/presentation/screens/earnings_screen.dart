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

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Earnings',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: earningsAsync.when(
        data: (earnings) => trendAsync.when(
          data: (trend) => _buildContent(context, earnings, trend),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    dynamic earnings,
    double trend,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Month dropdown
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'This Month',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'October',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Total balance section
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Text(
                  'Total Balance',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '\$${earnings.totalBalance.toStringAsFixed(2)}',
                  style: AppTypography.headlineLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Trend indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      trend >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: trend >= 0
                          ? AppColors.success
                          : AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${trend >= 0 ? '+' : ''}${trend.toStringAsFixed(1)}% vs last month',
                      style: AppTypography.labelMedium.copyWith(
                        color: trend >= 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Stats cards row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                EarningsStatCard(
                  label: 'Gross Income',
                  value: '\$${earnings.grossIncome.toStringAsFixed(2)}',
                  backgroundColor: AppColors.success.withOpacity(0.1),
                  textColor: AppColors.success,
                ),
                const SizedBox(width: AppSpacing.md),
                EarningsStatCard(
                  label: 'Platform Fee (10%)',
                  value: '-\$${earnings.platformFee.toStringAsFixed(2)}',
                  backgroundColor: AppColors.error.withOpacity(0.1),
                  textColor: AppColors.error,
                ),
                const SizedBox(width: AppSpacing.md),
                EarningsStatCard(
                  label: 'Platform Fee (10%)',
                  value: '-\$${earnings.platformFee.toStringAsFixed(2)}',
                  backgroundColor: AppColors.error.withOpacity(0.1),
                  textColor: AppColors.error,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Recent payouts section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Payouts',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Payouts list
                ...earnings.payouts.asMap().entries.map((entry) {
                  final payout = entry.value;
                  return PayoutTile(
                    title: 'Weekly Payout',
                    date: _formatDate(payout.date),
                    amount: payout.amount,
                    isPositive: true,
                  );
                }).toList(),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
        ],
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
