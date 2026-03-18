import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
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

/// Host dashboard screen
/// Responsive Web Layout: 
/// Desktop (≥800px): Two-column masonry grid style for widgets.
/// Mobile: Standard stacked layout.
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

    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: isDesktop ? null : IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        actions: [
          const SizedBox(width: AppSpacing.sm),
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.md),
            child: IconButton(
              icon: const Icon(Icons.calendar_month_rounded),
              color: AppColors.primary,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => context.push('/host-calendar'),
              tooltip: 'View Bookings Calendar',
            ),
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => thisMonthAsync.when(
          data: (thisMonth) => isDesktop 
            ? _buildDesktopContent(context, ref, stats, thisMonth)
            : _buildMobileContent(context, ref, stats, thisMonth),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context, WidgetRef ref, dynamic stats, double thisMonth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HostStatsHeader(
            hostName: hostName,
            hostPhotoUrl: hostPhotoUrl,
            isSuperhost: isSuperhost,
            thisMonthEarnings: thisMonth,
            averageRating: stats.averageRating,
            stats: stats,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildVerificationBannerWrapper(),
          _buildProfileCompletionSection(context, stats.profileCompletion),
          const SizedBox(height: AppSpacing.md),
          PerformanceSection(
            responseRate: stats.responseRate,
            acceptanceRate: stats.acceptanceRate,
            totalBookings: stats.totalBookings,
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildPendingBookingsSection(context),
          const SizedBox(height: AppSpacing.lg),
          _buildConfirmedBookingsSection(context),
          const SizedBox(height: AppSpacing.lg),
          _buildOngoingBookingsSection(context),
          const SizedBox(height: AppSpacing.lg),
          _buildActiveExperiencesSection(context, ref),
          const SizedBox(height: AppSpacing.lg),
          _buildCompletedBookingsSection(context),
        ],
      ),
    );
  }

  Widget _buildDesktopContent(BuildContext context, WidgetRef ref, dynamic stats, double thisMonth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl, vertical: AppSpacing.md),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               _buildVerificationBannerWrapper(),
               Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   // Left Dashboard Column
                   Expanded(
                     flex: 4,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         HostStatsHeader(
                            hostName: hostName,
                            hostPhotoUrl: hostPhotoUrl,
                            isSuperhost: isSuperhost,
                            thisMonthEarnings: thisMonth,
                            averageRating: stats.averageRating,
                            stats: stats,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _buildProfileCompletionSection(context, stats.profileCompletion),
                          const SizedBox(height: AppSpacing.xl),
                          PerformanceSection(
                            responseRate: stats.responseRate,
                            acceptanceRate: stats.acceptanceRate,
                            totalBookings: stats.totalBookings,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _buildPendingBookingsSection(context),
                          const SizedBox(height: AppSpacing.xl),
                          _buildActiveExperiencesSection(context, ref),
                       ],
                     ),
                   ),
                   const SizedBox(width: AppSpacing.xxxl),
                   // Right Dashboard Column
                   Expanded(
                     flex: 6,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          _buildConfirmedBookingsSection(context),
                          const SizedBox(height: AppSpacing.xl),
                          _buildOngoingBookingsSection(context),
                          const SizedBox(height: AppSpacing.xl),
                          _buildCompletedBookingsSection(context),
                       ],
                     ),
                   )
                 ],
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationBannerWrapper() {
    return Consumer(
      builder: (context, ref, child) {
        final userAsync = ref.watch(currentUserProvider);
        return userAsync.when(
          data: (user) {
            if (user == null || user.hostVerificationStatus == HostVerificationStatus.verified) {
              return const SizedBox.shrink(); 
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildVerificationBanner(context, user.hostVerificationStatus),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildVerificationBanner(BuildContext context, HostVerificationStatus status) {
    Color bgColor = AppColors.warning.withOpacity(0.1);
    Color iconColor = AppColors.warning;
    IconData icon = Icons.info_outline_rounded;
    String message = 'Complete your host verification to start accepting bookings.';
    String buttonText = 'Verify Now';
    String route = '/host-verification';

    if (status == HostVerificationStatus.pending) {
       bgColor = AppColors.info.withOpacity(0.1);
       iconColor = AppColors.info;
       icon = Icons.hourglass_top_rounded;
       message = 'Your verification is pending review.';
       buttonText = 'View Status';
       route = '/host-verification-pending';
    } else if (status == HostVerificationStatus.rejected) {
       bgColor = AppColors.error.withOpacity(0.1);
       iconColor = AppColors.error;
       icon = Icons.error_outline_rounded;
       message = 'Your verification was rejected. Please review and try again.';
       buttonText = 'Try Again';
       route = '/host-verification';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
            ),
          ),
          TextButton(
             onPressed: () => context.push(route),
             child: Text(buttonText, style: AppTypography.labelMedium.copyWith(color: iconColor, fontWeight: FontWeight.bold)),
          )
        ],
      )
    );
  }

  Widget _buildProfileCompletionSection(BuildContext context, int completionScore) {
    if (completionScore >= 100) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profile Completion',
                  style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$completionScore%',
                  style: AppTypography.labelLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: completionScore / 100,
              backgroundColor: AppColors.border,
              color: AppColors.primary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Complete your profile to attract more seekers and build trust.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingBookingsSection(BuildContext context) {
    return _buildStreamSection(
      context: context,
      title: 'Pending Bookings',
      query: FirebaseFirestore.instance.collection('bookings')
        .where('hostId', isEqualTo: hostId)
        .where('status', isEqualTo: 'pending'),
      emptyMessage: 'No pending requests.',
      builder: (context, docs) {
         final validBookings = <QueryDocumentSnapshot>[];
         for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              final createdAt = data['createdAt'] as Timestamp?;
              if (createdAt != null) {
                final age = DateTime.now().difference(createdAt.toDate());
                if (age.inHours >= 48) {
                  FirebaseFirestore.instance.collection('bookings').doc(doc.id).update({'status': 'expired'});
                  continue; 
                }
              }
              validBookings.add(doc);
         }
         return Column(
           children: validBookings.map((doc) {
             final data = doc.data() as Map<String, dynamic>;
             return PendingBookingTile(
               booking: data,
               onAccept: () {
                 FirebaseFirestore.instance.collection('bookings').doc(doc.id).update({'status': 'confirmed'});
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking accepted!'), backgroundColor: Colors.green));
               },
               onReject: () {
                 FirebaseFirestore.instance.collection('bookings').doc(doc.id).update({'status': 'rejected'});
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking rejected.')));
               },
             );
           }).cast<Widget>().toList(),
         );
      }
    );
  }

  Widget _buildConfirmedBookingsSection(BuildContext context) {
     return _buildStreamSection(
       context: context,
       title: 'Confirmed Bookings',
       subtitle: 'Upcoming experiences ready to be started',
       query: FirebaseFirestore.instance.collection('bookings')
          .where('hostId', isEqualTo: hostId)
          .where('status', isEqualTo: 'confirmed'),
       emptyMessage: 'No confirmed bookings.',
       builder: (context, docs) {
         return Column(
           children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final date = data['date'] is Timestamp ? (data['date'] as Timestamp).toDate() : DateTime.now();
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
                                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5),
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
                          style: AppTypography.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _SeekerAvatar(userId: data['userId'] ?? '', initialPhotoUrl: data['seekerPhotoUrl'], radius: 12),
                        const SizedBox(width: 8),
                        _SeekerNameText(userId: data['userId'] ?? '', initialName: data['seekerName'], style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 12),
                        const Icon(Icons.people_outline, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('${data['guests'] ?? 1}', style: AppTypography.bodySmallSecondary),
                        const Spacer(),
                        SizedBox(
                          height: 38,
                          child: ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance.collection('bookings').doc(doc.id).update({'status': 'ongoing'});
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Experience started!'), backgroundColor: AppColors.primary));
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 16)),
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
       }
     );
  }

  Widget _buildOngoingBookingsSection(BuildContext context) {
    return _buildStreamSection(
       context: context,
       title: 'Ongoing Bookings',
       subtitle: 'Experiences currently in progress',
       query: FirebaseFirestore.instance.collection('bookings')
          .where('hostId', isEqualTo: hostId)
          .where('status', isEqualTo: 'ongoing'),
       emptyMessage: 'No ongoing bookings.',
       builder: (context, docs) {
         return Column(
           children: docs.map((doc) {
             final data = doc.data() as Map<String, dynamic>;
             return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.primaryExtraLight, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              const Icon(Icons.play_circle_filled_rounded, size: 14, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text('ONGOING', style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
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
                              style: AppTypography.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(data['experienceTitle'] ?? 'Experience', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('Started at ${data['startTime'] ?? ''}', style: AppTypography.bodySmallSecondary),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _SeekerAvatar(userId: data['userId'] ?? '', initialPhotoUrl: data['seekerPhotoUrl'], radius: 12),
                        const SizedBox(width: 8),
                         _SeekerNameText(userId: data['userId'] ?? '', initialName: data['seekerName'], style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text('Awaiting completion...', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ],
                ),
              );
           }).toList(),
         );
       }
     );
  }

  Widget _buildCompletedBookingsSection(BuildContext context) {
    return _buildStreamSection(
       context: context,
       title: 'Completed Bookings',
       titleIcon: const Icon(Icons.check_circle, color: AppColors.success, size: 18),
       titleIconBg: AppColors.success.withAlpha(25),
       subtitle: 'Experiences that seekers have paid and completed',
       query: FirebaseFirestore.instance.collection('bookings')
          .where('hostId', isEqualTo: hostId)
          .where('status', isEqualTo: 'completed')
          .orderBy('updatedAt', descending: true)
          .limit(10),
       emptyMessage: 'No completed bookings down here.',
       builder: (context, docs) {
         return Column(
            children: docs.map((doc) {
               final data = doc.data() as Map<String, dynamic>;
               final date = data['date'] is Timestamp ? (data['date'] as Timestamp).toDate() : DateTime.now();
               final isPaid = data['paymentStatus'] == 'paid';
               
               return Container(
                 margin: const EdgeInsets.only(bottom: 12),
                 decoration: BoxDecoration(
                   color: AppColors.surface,
                   borderRadius: BorderRadius.circular(16),
                   border: Border.all(color: AppColors.border),
                 ),
                 child: ListTile(
                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                   leading: CircleAvatar(
                      backgroundColor: isPaid ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                      child: Icon(
                        isPaid ? Icons.check_circle_outline : Icons.pending_actions,
                        color: isPaid ? AppColors.success : AppColors.warning,
                      ),
                   ),
                   title: Text(data['experienceTitle'] ?? 'Experience', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600)),
                   subtitle: Text('${date.day}/${date.month}/${date.year} • ${data['guests']} guests', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                   trailing: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     crossAxisAlignment: CrossAxisAlignment.end,
                     children: [
                        Text('LKR ${(data['totalPrice'] as num?)?.toStringAsFixed(0) ?? '0'}', style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                        Text(isPaid ? 'Paid' : 'Unpaid', style: AppTypography.labelSmall.copyWith(color: isPaid ? AppColors.success : AppColors.warning)),
                     ],
                   ),
                 ),
               );
            }).toList()
         );
       }
    );
  }

  Widget _buildActiveExperiencesSection(BuildContext context, WidgetRef ref) {
    return _buildStreamSection(
      context: context,
      title: 'Active Experiences',
      query: FirebaseFirestore.instance.collection('experiences').where('hostId', isEqualTo: hostId),
      emptyMessage: 'No experiences listed yet.',
      builder: (context, docs) {
        return Column(
          children: docs.map((doc) {
             final data = doc.data() as Map<String, dynamic>;
             return ActiveExperienceTile(
               experienceId: doc.id,
               title: data['title'] ?? 'Untitled Experience',
               thumbnailUrl: data['coverImage'] as String?,
               onEditPressed: () {
                 // Placeholder, needs implementation if routing needed
               },
               onDeletePressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Experience'),
                      content: const Text('Are you sure you want to delete this listing? This action cannot be undone.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        TextButton(
                           onPressed: () async {
                              final expId = doc.id;
                              final expTitle = data['title'] ?? 'Experience';
                              Navigator.pop(ctx);
                              await FirebaseFirestore.instance.collection('experiences').doc(expId).delete();
                              ref.invalidate(featuredExperiencesProvider);
                              ref.invalidate(experiencesByFilterProvider);
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
      }
    );
  }

  // Helper method for streams
  Widget _buildStreamSection({
    required BuildContext context,
    required String title,
    String? subtitle,
    Icon? titleIcon,
    Color? titleIconBg,
    required Query query,
    required String emptyMessage,
    required Widget Function(BuildContext, List<QueryDocumentSnapshot>) builder,
  }) {
    return Padding(
       padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            Row(
              children: [
                if (titleIcon != null) ...[
                   Container(
                     padding: const EdgeInsets.all(6),
                     decoration: BoxDecoration(color: titleIconBg ?? AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.sm)),
                     child: titleIcon,
                   ),
                   const SizedBox(width: AppSpacing.sm),
                ],
                Text(title, style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
              ],
            ),
            if (subtitle != null) ...[
               const SizedBox(height: AppSpacing.sm),
               Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
            const SizedBox(height: AppSpacing.md),
            StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                 if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                 if (snapshot.hasError) return Text('Error loading: ${snapshot.error}');
                 final docs = snapshot.data?.docs ?? [];
                 if (docs.isEmpty) return Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm), child: Text(emptyMessage, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)));
                 return builder(context, docs);
              },
            ),
         ],
       ),
    );
  }

  void _showReportSheet(BuildContext context, String bookingId, String reportedUserId) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    if (isDesktop) {
        showDialog(
           context: context,
           builder: (_) => Dialog(
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
             child: SizedBox(
                width: 500,
                height: 480,
                child: ReportSheet(
                  reportedUserId: reportedUserId,
                  bookingId: bookingId,
                  reporterRole: 'host',
                  reportedRole: 'seeker',
                ),
             ),
           ),
        );
    } else {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ReportSheet(
            reportedUserId: reportedUserId,
            bookingId: bookingId,
            reporterRole: 'host',
            reportedRole: 'seeker',
          ),
        );
    }
  }

}

class _SeekerAvatar extends StatelessWidget {
  final String userId;
  final String? initialPhotoUrl;
  final double radius;

  const _SeekerAvatar({
    required this.userId,
    this.initialPhotoUrl,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        String? photoUrl = initialPhotoUrl;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (data['photoUrl'] != null && data['photoUrl'].toString().isNotEmpty) {
            photoUrl = data['photoUrl'];
          }
        }
        
        if (photoUrl != null && photoUrl.isNotEmpty) {
          return CircleAvatar(
            radius: radius,
            backgroundImage: NetworkImage(photoUrl),
            backgroundColor: AppColors.primaryExtraLight,
          );
        }
        
        return CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.primaryExtraLight,
          child: Icon(Icons.person, color: AppColors.primary, size: radius * 1.2),
        );
      },
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
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        String name = initialName ?? 'Seeker';
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (data['displayName'] != null && data['displayName'].toString().isNotEmpty) {
            name = data['displayName'];
          }
        }
        
        return Text(
          name,
          style: style,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
