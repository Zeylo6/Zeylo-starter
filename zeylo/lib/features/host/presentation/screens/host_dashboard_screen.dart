import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';
import '../providers/host_provider.dart';
import '../widgets/active_experience_tile.dart';
import '../widgets/active_experience_tile.dart';
import '../widgets/host_stats_header.dart';
import '../widgets/performance_section.dart';
import '../widgets/pending_booking_tile.dart';
import '../../../../features/booking/presentation/widgets/report_sheet.dart';
import '../../../../features/home/presentation/providers/home_provider.dart';
import '../../../../features/review/presentation/widgets/rate_and_review_sheet.dart';
import '../../../../features/booking/domain/entities/booking_entity.dart';

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
            ref,
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
    WidgetRef ref,
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

          // Host Verification Status Section
          Consumer(
            builder: (context, ref, child) {
              final userAsync = ref.watch(currentUserProvider);
              return userAsync.when(
                data: (user) {
                  if (user == null || user.hostVerificationStatus == HostVerificationStatus.verified) {
                    return const SizedBox.shrink(); // Hide if verified
                  }
                  return _buildVerificationBanner(context, user.hostVerificationStatus);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),

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
                        final age =
                            DateTime.now().difference(createdAt.toDate());
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
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Text(
                          'No pending requests.',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
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
                              const SnackBar(
                                  content: Text('Booking accepted!',
                                      style: TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.green),
                            );
                          },
                          onReject: () {
                            FirebaseFirestore.instance
                                .collection('bookings')
                                .doc(doc.id)
                                .update({'status': 'rejected'});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Booking rejected.')),
                            );
                          },
                        );
                      }).cast<Widget>().toList(),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Confirmed Bookings section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Confirmed Bookings',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Upcoming experiences ready to be started',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('bookings')
                      .where('hostId', isEqualTo: hostId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Text(
                          'Error loading confirmed bookings: ${snapshot.error}');
                    }

                    final allBookings = snapshot.data?.docs ?? [];
                    final confirmedBookings = allBookings.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['status'] == 'confirmed';
                    }).toList();

                    if (confirmedBookings.isEmpty) {
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Text(
                          'No confirmed bookings.',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    return Column(
                      children: confirmedBookings.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final date = data['date'] is Timestamp
                            ? (data['date'] as Timestamp).toDate()
                            : DateTime.now();

                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['experienceTitle'] ??
                                              'Experience',
                                          style: AppTypography.labelMedium
                                              .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          '${date.day}/${date.month}/${date.year} at ${data['startTime'] ?? ''}',
                                          style:
                                              AppTypography.bodySmall.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${(data['totalPrice'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline,
                                      size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${data['guests'] ?? 1} guest(s)',
                                    style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary),
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    height: 36,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('bookings')
                                            .doc(doc.id)
                                            .update({'status': 'ongoing'});

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Experience started! It is now ongoing.'),
                                              backgroundColor:
                                                  AppColors.primary,
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.sm),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                      ),
                                      child: const Text('Start Experience',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Ongoing Bookings section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ongoing Bookings',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Experiences currently in progress',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('bookings')
                      .where('hostId', isEqualTo: hostId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Text(
                          'Error loading ongoing bookings: ${snapshot.error}');
                    }

                    final allBookings = snapshot.data?.docs ?? [];
                    final ongoingBookings = allBookings.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['status'] == 'ongoing';
                    }).toList();

                    if (ongoingBookings.isEmpty) {
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Text(
                          'No ongoing bookings.',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    return Column(
                      children: ongoingBookings.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final date = data['date'] is Timestamp
                            ? (data['date'] as Timestamp).toDate()
                            : DateTime.now();

                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                                color: AppColors.primary.withAlpha(80)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withAlpha(30),
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.full),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'ONGOING',
                                          style:
                                              AppTypography.labelSmall.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => _showReportSheet(
                                            context, doc.id, data['userId']),
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              right: AppSpacing.sm),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.error
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.sm),
                                            border: Border.all(
                                                color: AppColors.error
                                                    .withOpacity(0.5)),
                                          ),
                                          child: const Icon(Icons.flag_rounded,
                                              size: 16, color: AppColors.error),
                                        ),
                                      ),
                                      Text(
                                        '\$${(data['totalPrice'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                        style:
                                            AppTypography.labelMedium.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                data['experienceTitle'] ?? 'Experience',
                                style: AppTypography.labelMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${date.day}/${date.month}/${date.year} at ${data['startTime'] ?? ''}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline,
                                      size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${data['guests'] ?? 1} guest(s)',
                                    style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                      return Text(
                          'Error loading experiences: ${snapshot.error}');
                    }

                    final exps = snapshot.data?.docs ?? [];

                    if (exps.isEmpty) {
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Text(
                          'No experiences listed yet.',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    return Column(
                      children: exps.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return ActiveExperienceTile(
                          experienceId: doc.id,
                          title: data['title'] ?? 'Untitled Experience',
                          thumbnailUrl: data['coverImage'] as String?,
                          onEditPressed: () {
                            _showEditExperienceSheet(context, doc.id, data);
                          },
                          onDeletePressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Experience'),
                                content: const Text(
                                    'Are you sure you want to delete this listing? This action cannot be undone.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final expId = doc.id;
                                      final expTitle =
                                          data['title'] ?? 'Experience';
                                      Navigator.pop(ctx);

                                      // 1. Delete the experience
                                      await FirebaseFirestore.instance
                                          .collection('experiences')
                                          .doc(expId)
                                          .delete();

                                      // Refetch home and search
                                      ref.invalidate(featuredExperiencesProvider);
                                      ref.invalidate(experiencesByFilterProvider);

                                      // 2. Cancel active bookings & notify seekers
                                      final bookingsSnap =
                                          await FirebaseFirestore.instance
                                              .collection('bookings')
                                              .where('experienceId',
                                                  isEqualTo: expId)
                                              .get();

                                      for (var booking in bookingsSnap.docs) {
                                        final bStatus =
                                            booking.data()['status'];
                                        if (bStatus == 'pending' ||
                                            bStatus == 'confirmed') {
                                          await booking.reference.update(
                                              {'status': 'cancelled_by_host'});

                                          // Send notification to the seeker
                                          await FirebaseFirestore.instance
                                              .collection('activities')
                                              .add({
                                            'userId': booking.data()['userId'],
                                            'title': 'Booking Cancelled',
                                            'message':
                                                'The host has cancelled the listing for $expTitle.',
                                            'createdAt':
                                                FieldValue.serverTimestamp(),
                                            'type': 'booking_cancellation',
                                            'isRead': false,
                                          });
                                        }
                                      }

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Experience deleted and upcoming bookings cancelled.')),
                                        );
                                      }
                                    },
                                    child: const Text('Delete',
                                        style: TextStyle(color: Colors.red)),
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

          // Completed & Paid Bookings section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(25),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(Icons.check_circle,
                          color: AppColors.success, size: 18),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Completed Bookings',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Experiences that seekers have paid and completed',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('bookings')
                      .where('hostId', isEqualTo: hostId)
                      // Removed multiple filters and orderBy to avoid composite index requirement
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Text(
                          'Error loading completed bookings: ${snapshot.error}');
                    }

                    // Filter and sort in memory
                    final allDocs = snapshot.data?.docs ?? [];
                    final docs = allDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['status'] == 'completed' &&
                          data['paymentStatus'] == 'paid';
                    }).toList();

                    // Sort by updatedAt descending
                    docs.sort((a, b) {
                      final aTime = (a.data()
                          as Map<String, dynamic>)['updatedAt'] as Timestamp?;
                      final bTime = (b.data()
                          as Map<String, dynamic>)['updatedAt'] as Timestamp?;
                      if (aTime == null || bTime == null) return 0;
                      return bTime.compareTo(aTime);
                    });

                    // Limit to 10
                    final limitedDocs = docs.take(10).toList();

                    if (limitedDocs.isEmpty) {
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Center(
                          child: Column(
                            children: [
                              const Text('🎯', style: TextStyle(fontSize: 36)),
                              const SizedBox(height: 8),
                              Text(
                                'No completed bookings yet',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: limitedDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final date = data['date'] is Timestamp
                            ? (data['date'] as Timestamp).toDate()
                            : DateTime.now();
                        final bool isRatedByHost = data['isRatedByHost'] == true;

                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: AppColors.success.withAlpha(60),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.success.withAlpha(25),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                                child: const Icon(
                                  Icons.event_available,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['experienceTitle'] ?? 'Experience',
                                      style: AppTypography.labelMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${date.day}/${date.month}/${date.year}  •  ${data['guests'] ?? 1} guest(s)',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withAlpha(25),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.full),
                                ),
                                child: Text(
                                  '\$${(data['totalPrice'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                                ],
                              ),
                              if (!isRatedByHost) ...[
                                const SizedBox(height: AppSpacing.md),
                                SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Mock booking entity for review sheet
                                  final mockBooking = BookingEntity(
                                    id: doc.id,
                                    experienceId: data['experienceId'] ?? '',
                                    experienceTitle: data['experienceTitle'] ?? 'Experience',
                                    experienceCoverImage: '',
                                    userId: data['userId'] ?? '',
                                    hostId: hostId,
                                    date: date,
                                    startTime: data['startTime'] ?? '',
                                    guests: data['guests'] ?? 1,
                                    totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
                                    status: data['status'] ?? 'completed',
                                    paymentStatus: data['paymentStatus'] ?? 'paid',
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                  );
                                  
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => RateAndReviewSheet(
                                      booking: mockBooking,
                                      reviewerRole: 'host',
                                      onSuccess: () {},
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.star_outline_rounded, size: 18),
                                label: const Text('Rate Seeker'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).cast<Widget>().toList(),
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

  Widget _buildVerificationBanner(BuildContext context, HostVerificationStatus status) {
    Color bannerColor;
    IconData iconData;
    String title;
    String description;
    String actionText;
    VoidCallback onTap;

    switch (status) {
      case HostVerificationStatus.unverified:
        bannerColor = AppColors.error;
        iconData = Icons.gpp_bad_outlined;
        title = 'Verification Required';
        description = 'You must verify your identity to list experiences and accept bookings.';
        actionText = 'Verify Now';
        onTap = () => context.push('/host-verification');
        break;
      case HostVerificationStatus.pending:
        bannerColor = AppColors.warning;
        iconData = Icons.hourglass_empty;
        title = 'Verification Pending';
        description = 'Your identity documents are currently under review by our team.';
        actionText = 'View Status';
        onTap = () => context.push('/host-verification-pending');
        break;
      case HostVerificationStatus.rejected:
        bannerColor = AppColors.error;
        iconData = Icons.error_outline;
        title = 'Verification Rejected';
        description = 'Your previous verification attempt was rejected. Please review and try again.';
        actionText = 'Try Again';
        onTap = () => context.push('/host-verification');
        break;
      case HostVerificationStatus.verified:
        return const SizedBox.shrink(); // Handled above
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: bannerColor.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: bannerColor, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    color: bannerColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    actionText,
                    style: AppTypography.labelMedium.copyWith(
                      color: bannerColor,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReportSheet(
      BuildContext context, String bookingId, String reportedUserId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportSheet(
        reportedUserId: reportedUserId, // Host is reporting the Seeker
        bookingId: bookingId,
        reporterRole: 'host',
        reportedRole: 'seeker',
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

  void _showEditExperienceSheet(
      BuildContext context, String expId, Map<String, dynamic> data) {
    final titleController = TextEditingController(text: data['title'] ?? '');
    final shortDescController =
        TextEditingController(text: data['shortDescription'] ?? '');
    final descController =
        TextEditingController(text: data['description'] ?? '');
    final priceController =
        TextEditingController(text: (data['price'] ?? 0).toString());
    final durationController =
        TextEditingController(text: (data['duration'] ?? 0).toString());
    final maxGuestsController =
        TextEditingController(text: (data['maxGuests'] ?? 0).toString());

    // Handle location structure
    final location = data['location'] as Map<String, dynamic>?;
    final addressController =
        TextEditingController(text: location?['address'] ?? '');
    final cityController = TextEditingController(text: location?['city'] ?? '');

    String currentImageUrl = data['coverImage'] ?? '';
    File? selectedImage;
    bool isSaving = false;
    final ImagePicker picker = ImagePicker();

    // Cloudinary credentials (same as CreateExperienceScreen)
    const cloudName = 'deukwmcoi';
    const uploadPreset = 'Zeylo_images';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            Future<void> pickImage() async {
              try {
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1080,
                  maxHeight: 1080,
                  imageQuality: 85,
                );
                if (image != null) {
                  setSheetState(() => selectedImage = File(image.path));
                }
              } catch (e) {
                debugPrint("Picker error: $e");
              }
            }

            Future<String?> uploadToCloudinary() async {
              if (selectedImage == null) return currentImageUrl;
              try {
                final url = Uri.parse(
                    'https://api.cloudinary.com/v1_1/$cloudName/image/upload');
                final request = http.MultipartRequest('POST', url)
                  ..fields['upload_preset'] = uploadPreset
                  ..files.add(await http.MultipartFile.fromPath(
                      'file', selectedImage!.path));

                final response = await request.send();
                final responseData = await response.stream.toBytes();
                final responseString = String.fromCharCodes(responseData);
                final jsonMap = jsonDecode(responseString);

                if (response.statusCode == 200) {
                  return jsonMap['secure_url'];
                }
                return null;
              } catch (e) {
                debugPrint("Upload error: $e");
                return null;
              }
            }

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.85,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Edit Experience',
                            style: AppTypography.titleLarge),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Image Picker Logic
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: selectedImage != null
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                child: Image.file(selectedImage!,
                                    fit: BoxFit.cover),
                              )
                            : (currentImageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.md),
                                    child: Image.network(currentImageUrl,
                                        fit: BoxFit.cover),
                                  )
                                : const Center(
                                    child: Icon(Icons.add_a_photo,
                                        size: 40,
                                        color: AppColors.textSecondary))),
                      ),
                    ),
                    const Center(
                        child: Text('Tap to change photo',
                            style:
                                TextStyle(fontSize: 12, color: Colors.grey))),
                    const SizedBox(height: AppSpacing.md),

                    _buildEditField(titleController, 'Experience Title'),
                    const SizedBox(height: AppSpacing.md),
                    _buildEditField(shortDescController, 'Short Description'),
                    const SizedBox(height: AppSpacing.md),
                    _buildEditField(descController, 'Full Description',
                        maxLines: 5),
                    const SizedBox(height: AppSpacing.md),

                    Row(
                      children: [
                        Expanded(
                            child: _buildEditField(
                                priceController, 'Price (USD)',
                                isNumber: true)),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                            child: _buildEditField(
                                durationController, 'Duration (mins)',
                                isNumber: true)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildEditField(maxGuestsController, 'Max Guests',
                        isNumber: true),
                    const SizedBox(height: AppSpacing.md),

                    Text('Location',
                        style: AppTypography.labelLarge
                            .copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.sm),
                    _buildEditField(addressController, 'Street Address'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildEditField(cityController, 'City'),

                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md)),
                        ),
                        onPressed: isSaving
                            ? null
                            : () async {
                                setSheetState(() => isSaving = true);
                                try {
                                  // 1. Upload new image if selected
                                  final finalImageUrl =
                                      await uploadToCloudinary();
                                  if (finalImageUrl == null &&
                                      selectedImage != null) {
                                    throw Exception("Image upload failed");
                                  }

                                  // 2. Update Firestore
                                  await FirebaseFirestore.instance
                                      .collection('experiences')
                                      .doc(expId)
                                      .update({
                                    'title': titleController.text.trim(),
                                    'shortDescription':
                                        shortDescController.text.trim(),
                                    'description': descController.text.trim(),
                                    'price': double.tryParse(
                                            priceController.text.trim()) ??
                                        0,
                                    'duration': int.tryParse(
                                            durationController.text.trim()) ??
                                        0,
                                    'maxGuests': int.tryParse(
                                            maxGuestsController.text.trim()) ??
                                        0,
                                    'coverImage': finalImageUrl,
                                    'images': [
                                      finalImageUrl
                                    ], // Resetting images list for now
                                    'location.address':
                                        addressController.text.trim(),
                                    'location.city': cityController.text.trim(),
                                    'updatedAt': FieldValue.serverTimestamp(),
                                  });

                                  if (context.mounted) {
                                    Navigator.pop(sheetContext);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Experience updated successfully!')),
                                    );
                                  }
                                } catch (e) {
                                  setSheetState(() => isSaving = false);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text('Failed to save: $e')),
                                    );
                                  }
                                }
                              },
                        child: isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Save Changes',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEditField(TextEditingController controller, String label,
      {int maxLines = 1, bool isNumber = false}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}
