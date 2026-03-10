import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/host_provider.dart';
import '../widgets/active_experience_tile.dart';
import '../widgets/host_stats_header.dart';
import '../widgets/performance_section.dart';
import '../widgets/pending_booking_tile.dart';

/// Host dashboard screen
class HostDashboardScreen extends ConsumerWidget {
  final String hostId;
  final String hostName;
  final String? hostPhotoUrl;
  final bool isSuperhost;

  const HostDashboardScreen({
    required this.hostId,
    required this.hostName,
    this.hostPhotoUrl,
    this.isSuperhost = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(hostStatsProvider(hostId));
    final thisMonthAsync = ref.watch(thisMonthEarningsProvider(hostId));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            color: AppColors.textPrimary,
            onPressed: () => context.push('/host-calendar'),
            tooltip: 'View Bookings Calendar',
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => thisMonthAsync.when(
          data: (thisMonth) => _buildContent(
            context,
            stats,
            thisMonth,
          ),
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
    dynamic stats,
    double thisMonth,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient
          HostStatsHeader(
            hostName: hostName,
            hostPhotoUrl: hostPhotoUrl,
            isSuperhost: isSuperhost,
            thisMonthEarnings: thisMonth,
            averageRating: stats.averageRating,
            stats: stats,
          ),

          const SizedBox(height: AppSpacing.md),

          // Profile completion section
          _buildProfileCompletionSection(context, stats.profileCompletion),

          const SizedBox(height: AppSpacing.md),

          // Performance section
          PerformanceSection(
            responseRate: stats.responseRate,
            acceptanceRate: stats.acceptanceRate,
            totalBookings: stats.totalBookings,
          ),

          const SizedBox(height: AppSpacing.md),

          // Pending Bookings section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pending Bookings',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('bookings')
                      .where('hostId', isEqualTo: hostId)
                      .where('status', isEqualTo: 'pending')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Text('Error loading bookings: ${snapshot.error}');
                    }

                    final bookings = snapshot.data?.docs ?? [];
                    final validBookings = <QueryDocumentSnapshot>[];

                    for (var doc in bookings) {
                      final data = doc.data() as Map<String, dynamic>;
                      final createdAt = data['createdAt'] as Timestamp?;
                      
                      if (createdAt != null) {
                        final age = DateTime.now().difference(createdAt.toDate());
                        if (age.inHours >= 48) {
                          // Auto-expire
                          FirebaseFirestore.instance
                              .collection('bookings')
                              .doc(doc.id)
                              .update({'status': 'expired'});
                          continue; // skip rendering
                        }
                      }
                      validBookings.add(doc);
                    }
                    
                    if (validBookings.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Text(
                          'No pending requests.',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    return Column(
                      children: validBookings.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return PendingBookingTile(
                          booking: data,
                          onAccept: () {
                            FirebaseFirestore.instance
                                .collection('bookings')
                                .doc(doc.id)
                                .update({'status': 'confirmed'});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Booking accepted!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
                            );
                          },
                          onReject: () {
                            FirebaseFirestore.instance
                                .collection('bookings')
                                .doc(doc.id)
                                .update({'status': 'rejected'});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Booking rejected.')),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Active experiences section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Experiences',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Experience list StreamBuilder
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('experiences')
                      .where('hostId', isEqualTo: hostId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Text('Error loading experiences: ${snapshot.error}');
                    }

                    final exps = snapshot.data?.docs ?? [];
                    
                    if (exps.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Text(
                          'No experiences listed yet.',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    return Column(
                      children: exps.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return ActiveExperienceTile(
                          experienceId: doc.id,
                          title: data['title'] ?? 'Untitled Experience',
                          onEditPressed: () {
                            // TODO: Implement edit functionality later
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Edit functionality coming soon!')),
                            );
                          },
                          onDeletePressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Experience'),
                                content: const Text('Are you sure you want to delete this listing? This action cannot be undone.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final expId = doc.id;
                                      final expTitle = data['title'] ?? 'Experience';
                                      Navigator.pop(ctx);
                                      
                                      // 1. Delete the experience
                                      await FirebaseFirestore.instance
                                          .collection('experiences')
                                          .doc(expId)
                                          .delete();
                                          
                                      // 2. Cancel active bookings & notify seekers
                                      final bookingsSnap = await FirebaseFirestore.instance
                                          .collection('bookings')
                                          .where('experienceId', isEqualTo: expId)
                                          .get();
                                          
                                      for (var booking in bookingsSnap.docs) {
                                        final bStatus = booking.data()['status'];
                                        if (bStatus == 'pending' || bStatus == 'confirmed') {
                                          await booking.reference.update({'status': 'cancelled_by_host'});
                                          
                                          // Send notification to the seeker
                                          await FirebaseFirestore.instance.collection('activities').add({
                                            'userId': booking.data()['userId'],
                                            'title': 'Booking Cancelled',
                                            'message': 'The host has cancelled the listing for $expTitle.',
                                            'createdAt': FieldValue.serverTimestamp(),
                                            'type': 'booking_cancellation',
                                            'isRead': false,
                                          });
                                        }
                                      }

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Experience deleted and upcoming bookings cancelled.')),
                                        );
                                      }
                                    },
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),


              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionSection(BuildContext context, int completion) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Completion',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$completion%',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: completion / 100,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Completion message
          Text(
            'Add 2 more photos to reach 100%',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
