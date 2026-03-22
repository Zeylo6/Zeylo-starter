import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import 'package:intl/intl.dart';
import 'package:zeylo/features/review/presentation/providers/review_provider.dart';

/// Glassmorphism notifications screen
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view notifications.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3EEFF),
              Color(0xFFF9F7FF),
              Color(0xFFEDE9FE),
              Color(0xFFF5F3FF),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            CustomScrollView(
              slivers: [
                // Glass app bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  floating: true,
                  snap: true,
                  toolbarHeight: 64,
                  flexibleSpace: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.5),
                              Colors.white.withOpacity(0.3),
                            ],
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withOpacity(0.5),
                              width: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Notifications',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w800,
                          )),
                    ],
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: GestureDetector(
                        onTap: () => _markAllAsRead(user.uid),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withOpacity(0.12),
                                    AppColors.gradientEnd.withOpacity(0.06),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Read All',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Notifications list
                SliverToBoxAdapter(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('activities')
                        .where('userId', isEqualTo: user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(AppSpacing.xxxl),
                          child: Center(
                              child: Text(
                                  'Error loading notifications: ${snapshot.error}',
                                  textAlign: TextAlign.center)),
                        );
                      }

                      var notifications = snapshot.data?.docs.toList() ?? [];
                      notifications.sort((a, b) {
                        final aData = a.data() as Map<String, dynamic>;
                        final bData = b.data() as Map<String, dynamic>;
                        final aTime = aData['createdAt'] as Timestamp?;
                        final bTime = bData['createdAt'] as Timestamp?;
                        if (aTime == null && bTime == null) return 0;
                        if (aTime == null) return 1;
                        if (bTime == null) return -1;
                        return bTime.compareTo(aTime);
                      });

                      if (notifications.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.xxl),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.xxxl),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.5),
                                        Colors.white.withOpacity(0.25),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.6),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primary.withOpacity(0.08),
                                        ),
                                        child: Icon(Icons.notifications_off_rounded,
                                            size: 32,
                                            color: AppColors.primary.withOpacity(0.5)),
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      Text('No notifications yet.',
                                          style: AppTypography.titleMedium.copyWith(
                                              color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: notifications.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final title = data['title'] ?? 'Notification';
                            final message = data['message'] ?? '';
                            final isRead = data['isRead'] ?? false;
                            final timestamp = data['createdAt'] as Timestamp?;

                            String timeAgo = '';
                            if (timestamp != null) {
                              timeAgo = DateFormat.yMMMd()
                                  .add_jm()
                                  .format(timestamp.toDate());
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.xl),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isRead
                                            ? [
                                                Colors.white.withOpacity(0.45),
                                                Colors.white.withOpacity(0.25),
                                              ]
                                            : [
                                                AppColors.primary.withOpacity(0.1),
                                                Colors.white.withOpacity(0.4),
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(AppRadius.xl),
                                      border: Border.all(
                                        color: isRead
                                            ? Colors.white.withOpacity(0.6)
                                            : AppColors.primary.withOpacity(0.3),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(AppRadius.xl),
                                      onTap: () {
                                        if (data['type'] == 'review_report' &&
                                            data['reviewId'] != null) {
                                          _showReviewManagementSheet(
                                              context, ref, data['reviewId'], doc.reference);
                                        } else if (!isRead) {
                                          doc.reference.update({'isRead': true});
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(AppSpacing.md),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Glass icon
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                    sigmaX: 6, sigmaY: 6),
                                                child: Container(
                                                  width: 42,
                                                  height: 42,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      colors: isRead
                                                          ? [
                                                              Colors.white.withOpacity(0.5),
                                                              Colors.white.withOpacity(0.25),
                                                            ]
                                                          : [
                                                              _getColorForType(data['type'])
                                                                  .withOpacity(0.15),
                                                              _getColorForType(data['type'])
                                                                  .withOpacity(0.06),
                                                            ],
                                                    ),
                                                    border: Border.all(
                                                      color: isRead
                                                          ? Colors.white.withOpacity(0.5)
                                                          : _getColorForType(data['type'])
                                                              .withOpacity(0.2),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    _getIconForType(data['type']),
                                                    size: 20,
                                                    color: isRead
                                                        ? AppColors.textSecondary
                                                        : _getColorForType(data['type']),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: AppSpacing.md),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    title,
                                                    style: AppTypography.labelLarge.copyWith(
                                                      fontWeight: isRead
                                                          ? FontWeight.w500
                                                          : FontWeight.w700,
                                                      color: isRead
                                                          ? AppColors.textSecondary
                                                          : AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: AppSpacing.xs),
                                                  Text(
                                                    message,
                                                    style: AppTypography.bodyMedium.copyWith(
                                                      color: isRead
                                                          ? AppColors.textSecondary
                                                          : AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: AppSpacing.xs),
                                                  Text(
                                                    timeAgo,
                                                    style: AppTypography.bodySmall.copyWith(
                                                        color: AppColors.textHint),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (!isRead)
                                              Container(
                                                width: 8,
                                                height: 8,
                                                margin: const EdgeInsets.only(top: 6),
                                                decoration: BoxDecoration(
                                                  gradient: AppColors.primaryGradient,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors.primary
                                                          .withOpacity(0.4),
                                                      blurRadius: 6,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'new_booking':           return Icons.bookmark_added_rounded;
      case 'booking_accepted':      return Icons.check_circle_outline_rounded;
      case 'booking_rejected':      return Icons.cancel_outlined;
      case 'booking_completed':     return Icons.star_outline_rounded;
      case 'booking_ongoing':       return Icons.play_circle_outline_rounded;
      case 'booking_cancellation':
      case 'booking_cancelled':     return Icons.cancel_presentation_rounded;
      case 'payment_received':      return Icons.payments_outlined;
      case 'mystery_booking':
      case 'mystery_booked':        return Icons.card_giftcard_rounded;
      case 'mystery_revealed':      return Icons.lock_open_rounded;
      case 'mystery_booking_accepted':
      case 'mystery_accepted':      return Icons.card_giftcard_rounded;
      case 'mystery_booking_declined':
      case 'mystery_declined':      return Icons.block_rounded;
      case 'mystery_auto_declined': return Icons.timer_off_rounded;
      case 'review_report':         return Icons.report_problem_rounded;
      default:                      return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(String? type) {
    if (type == null) return AppColors.primary;
    if (type.startsWith('mystery')) return const Color(0xFF7C3AED);
    if (type.contains('accepted') || type.contains('completed')) return const Color(0xFF059669);
    if (type.contains('declined') || type.contains('rejected') || type.contains('cancelled')) return const Color(0xFFEF4444);
    if (type.contains('payment')) return const Color(0xFF0EA5E9);
    return AppColors.primary;
  }

  Future<void> _showReviewManagementSheet(
    BuildContext context,
    WidgetRef ref,
    String reviewId,
    DocumentReference notificationRef,
  ) async {
    await notificationRef.update({'isRead': true});

    final reviewDoc =
        await FirebaseFirestore.instance.collection('reviews').doc(reviewId).get();
    if (!reviewDoc.exists) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This review has already been deleted.')),
        );
      }
      return;
    }

    final reviewData = reviewDoc.data()!;
    final message = reviewData['message'] ?? '(No message)';
    final rating = (reviewData['rating'] as num?)?.toDouble() ?? 0.0;

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.75),
                  Colors.white.withOpacity(0.55),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textHint.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Reported Review Mitigation',
                      style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'A guest has reported this review. As a host, you can choose to keep it or remove it.',
                    style: AppTypography.bodyMediumSecondary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Glass review preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.5),
                              Colors.white.withOpacity(0.25),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: Color(0xFFFFB800), size: 20),
                                const SizedBox(width: 4),
                                Text(rating.toStringAsFixed(1),
                                    style: AppTypography.labelLarge
                                        .copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(message, style: AppTypography.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('reviews')
                                .doc(reviewId)
                                .update({'isReported': false});
                            if (context.mounted) Navigator.pop(context);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Review kept. Report dismissed.')),
                              );
                            }
                          },
                          child: Text('Keep Review', style: AppTypography.labelLarge),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await ref
                                .read(reviewRepositoryProvider)
                                .deleteReview(reviewId);
                            if (context.mounted) Navigator.pop(context);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Review deleted.'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            elevation: 0,
                          ),
                          child: Text('Delete Review',
                              style: AppTypography.labelLarge
                                  .copyWith(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _markAllAsRead(String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final unreadDocs = await firestore
          .collection('activities')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      if (unreadDocs.docs.isEmpty) return;

      final batch = firestore.batch();
      for (var doc in unreadDocs.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }
}
