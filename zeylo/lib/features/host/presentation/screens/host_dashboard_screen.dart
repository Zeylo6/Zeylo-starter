import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';
import '../providers/host_provider.dart';
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
          const SizedBox(width: AppSpacing.sm),
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
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['experienceTitle'] ?? 'Experience',
                                          style: AppTypography.titleMedium.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${date.day}/${date.month}/${date.year} at ${data['startTime'] ?? ''}',
                                              style: AppTypography.bodySmallSecondary,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'LKR ${(data['totalPrice'] as num?)?.toStringAsFixed(0) ?? '0'}',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _SeekerAvatar(
                                    userId: data['userId'] ?? '',
                                    initialPhotoUrl: data['seekerPhotoUrl'] ?? data['seeker_photo_url'],
                                    radius: 12,
                                  ),
                                  const SizedBox(width: 8),
                                  _SeekerNameText(
                                    userId: data['userId'] ?? '',
                                    initialName: data['seekerName'] ?? data['seeker_name'],
                                    style: AppTypography.labelMedium.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.people_outline, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${data['guests'] ?? 1}',
                                    style: AppTypography.bodySmallSecondary,
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    height: 38,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('bookings')
                                            .doc(doc.id)
                                            .update({'status': 'ongoing'});

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Experience started! Enjoy the journey.'),
                                              backgroundColor: AppColors.primary,
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                      ),
                                      child: const Text('Start', style: TextStyle(fontWeight: FontWeight.bold)),
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

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.04),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryExtraLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.play_circle_filled_rounded, size: 14, color: AppColors.primary),
                                        const SizedBox(width: 6),
                                        Text(
                                          'ONGOING',
                                          style: AppTypography.labelSmall.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => _showReportSheet(context, doc.id, data['userId']),
                                        icon: const Icon(Icons.flag_rounded, size: 18, color: AppColors.error),
                                        visualDensity: VisualDensity.compact,
                                        tooltip: 'Report Seeker',
                                      ),
                                      Text(
                                        'LKR ${(data['totalPrice'] as num?)?.toStringAsFixed(0) ?? '0'}',
                                        style: AppTypography.titleMedium.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                data['experienceTitle'] ?? 'Experience',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Started at ${data['startTime'] ?? ''}',
                                    style: AppTypography.bodySmallSecondary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _SeekerAvatar(
                                    userId: data['userId'] ?? '',
                                    initialPhotoUrl: data['seekerPhotoUrl'] ?? data['seeker_photo_url'],
                                    radius: 12,
                                  ),
                                  const SizedBox(width: 8),
                                  _SeekerNameText(
                                    userId: data['userId'] ?? '',
                                    initialName: data['seekerName'] ?? data['seeker_name'],
                                    style: AppTypography.labelMedium.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Awaiting completion...',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontStyle: FontStyle.italic,
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
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF10B981),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
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
                                    Row(
                                      children: [
                                        Text(
                                          '${date.day}/${date.month}/${date.year}  •  ',
                                          style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        _SeekerAvatar(
                                          userId: data['userId'] ?? '',
                                          initialPhotoUrl: (data['seekerPhotoUrl'] ?? data['seeker_photo_url']),
                                          radius: 8,
                                        ),
                                        const SizedBox(width: 4),
                                        _SeekerNameText(
                                          userId: data['userId'] ?? '',
                                          initialName: (data['seekerName'] ?? data['seeker_name']),
                                          style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
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
                              if (data['isEarningsCollected'] != true) ...[
                                const SizedBox(height: AppSpacing.md),
                                SizedBox(
                                  width: double.infinity,
                                  child: ZeyloButton(
                                    onPressed: () => _collectEarnings(context, ref, doc.id, data),
                                    label: '💰  Collect Earnings',
                                    variant: ButtonVariant.filled,
                                    backgroundColor: AppColors.success,
                                  ),
                                ),
                              ],
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
                                    seekerName: data['seekerName'],
                                    seekerPhotoUrl: data['seekerPhotoUrl'] ?? data['seeker_photo_url'],
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
                                label: StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(data['userId'] ?? '')
                                      .snapshots(),
                                  builder: (context, userSnapshot) {
                                    String firstName = 'Seeker';
                                    if (userSnapshot.hasData && userSnapshot.data!.exists) {
                                      final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                                      final fullName = userData?['displayName'] as String? ?? data['seekerName'] ?? data['seeker_name'] ?? 'Seeker';
                                      firstName = fullName.split(' ').first;
                                    } else {
                                      firstName = (data['seekerName'] ?? data['seeker_name'] ?? 'Seeker').split(' ').first;
                                    }
                                    return Text('Rate $firstName');
                                  },
                                ),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: bannerColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bannerColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: bannerColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    color: bannerColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTypography.bodySmallSecondary,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: bannerColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      actionText,
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
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

  Future<void> _collectEarnings(BuildContext context, WidgetRef ref, String bookingId, Map<String, dynamic> data) async {
    final hostId = ref.read(currentUserProvider).value?.uid;
    if (hostId == null) return;

    try {
      final db = FirebaseFirestore.instance;
      final batch = db.batch();

      // 1. Update booking to mark earnings as collected
      final bookingRef = db.collection('bookings').doc(bookingId);
      batch.update(bookingRef, {
        'isEarningsCollected': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Record earnings in host's collection
      final earningsRef = db.collection('hosts').doc(hostId).collection('earnings').doc(bookingId);
      batch.set(earningsRef, {
        'amount': (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
        'date': FieldValue.serverTimestamp(),
        'bookingId': bookingId,
        'experienceTitle': data['experienceTitle'],
        'seekerName': data['seekerName'] ?? data['seeker_name'] ?? 'Seeker',
      });

      await batch.commit();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Earnings collected successfully! 💰'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to collect earnings: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Completion',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completion%',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress bar
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                height: 10,
                width: (MediaQuery.of(context).size.width - 80) * (completion / 100),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Completion message
          Row(
            children: [
              const Icon(Icons.info_outline, size: 14, color: AppColors.textHint),
              const SizedBox(width: 8),
              Text(
                'Add 2 more photos to reach 100%',
                style: AppTypography.bodySmallSecondary,
              ),
            ],
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

                                    // 2. Fetch latest host profile data
                                    final user = FirebaseAuth.instance.currentUser;
                                    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
                                    final userData = userDoc.data();

                                    // 3. Update Firestore
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
                                      'hostName': userData?['displayName'] ?? user?.displayName ?? 'Zeylo Host',
                                      'hostPhotoUrl': userData?['photoUrl'] ?? user?.photoURL ?? '',
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

class _SeekerNameText extends StatelessWidget {
  final String userId;
  final String? initialName;
  final TextStyle style;

  const _SeekerNameText({
    required this.userId,
    this.initialName,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (initialName != null &&
        initialName != 'Seeker' &&
        initialName!.trim().isNotEmpty) {
      return Text(initialName!, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Text(initialName ?? 'Seeker', style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
        }
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final name = data?['displayName'] as String? ?? initialName ?? 'Seeker';
        return Text(name, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
      },
    );
  }
}

class _SeekerAvatar extends StatelessWidget {
  final String userId;
  final String? initialPhotoUrl;
  final double radius;

  const _SeekerAvatar({
    required this.userId,
    this.initialPhotoUrl,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (initialPhotoUrl != null && initialPhotoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surface,
        backgroundImage: NetworkImage(initialPhotoUrl!),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        String? photoUrl = initialPhotoUrl;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          photoUrl = data?['photoUrl'] as String? ?? photoUrl;
        }

        return CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.surface,
          backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
              ? NetworkImage(photoUrl)
              : null,
          child: (photoUrl == null || photoUrl.isEmpty)
              ? Icon(Icons.person, size: radius * 1.2, color: AppColors.textSecondary)
              : null,
        );
      },
    );
  }
}
