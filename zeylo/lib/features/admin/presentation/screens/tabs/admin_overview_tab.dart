import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOverviewTab extends StatelessWidget {
  const AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Analytics',
            style: AppTypography.headlineMedium
                .copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'High-level overview of Zeylo\'s performance',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                  child: _MetricCard(
                      title: 'Total Users',
                      streamQuery: FirebaseFirestore.instance
                          .collection('users')
                          .snapshots(),
                      icon: Icons.group_rounded,
                      color: Colors.blue)),
              SizedBox(width: AppSpacing.md),
              Expanded(
                  child: _MetricCard(
                      title: 'Active Experiences',
                      streamQuery: FirebaseFirestore.instance
                          .collection('experiences')
                          .snapshots(),
                      icon: Icons.explore_rounded,
                      color: Colors.green)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                  child: _MetricCard(
                      title: 'Total Bookings',
                      streamQuery: FirebaseFirestore.instance
                          .collection('bookings')
                          .snapshots(),
                      icon: Icons.calendar_month_rounded,
                      color: Colors.orange)),
              SizedBox(width: AppSpacing.md),
              Expanded(child: _RevenueCard()),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Recent System Activity',
            style:
                AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppSpacing.md),
          _buildActivityFeed(),
        ],
      ),
    );
  }

  Widget _buildActivityFeed() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .orderBy('createdAt', descending: true)
            .limit(5)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Text('Error loading activity');
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No recent activity'),
            );
          }
          return Column(
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(Icons.receipt_long,
                      color: AppColors.primary, size: 18),
                ),
                title: Text(
                    'New booking for ${data['experienceTitle'] ?? 'Experience'}'),
                subtitle: Text(
                    'Status: ${data['status']} - \$${(data['totalPrice'] ?? 0).toString()}'),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final Stream<QuerySnapshot> streamQuery;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.streamQuery,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              StreamBuilder<QuerySnapshot>(
                stream: streamQuery,
                builder: (context, snapshot) {
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Text('--',
                        style: AppTypography.headlineMedium
                            .copyWith(fontWeight: FontWeight.bold));
                  }
                  return Text(
                    '${snapshot.data!.docs.length}',
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title,
              style: AppTypography.labelLarge
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.attach_money,
                    color: Colors.purple, size: 24),
              ),
              const Spacer(),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where('status', isEqualTo: 'completed')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Text('--',
                        style: AppTypography.headlineMedium
                            .copyWith(fontWeight: FontWeight.bold));
                  }
                  double total = 0;
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    total += (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
                  }
                  return Text(
                    '\$${total.toStringAsFixed(0)}',
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Total Processed Revenue',
              style: AppTypography.labelLarge
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
