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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Notifications', style: AppTypography.titleLarge),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () => _markAllAsRead(user.uid),
            child: Text(
              'Read All',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('activities')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text(
                    'Error loading notifications: ${snapshot.error}. Make sure indexes are built if needed.',
                    textAlign: TextAlign.center));
          }

          var notifications = snapshot.data?.docs.toList() ?? [];

          // Sort client-side to avoid needing a composite index in Firestore
          notifications.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = aData['createdAt'] as Timestamp?;
            final bTime = bData['createdAt'] as Timestamp?;

            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;

            return bTime.compareTo(aTime); // Descending order
          });

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 60, color: AppColors.textSecondary),
                  const SizedBox(height: AppSpacing.md),
                  Text('No notifications yet.',
                      style: AppTypography.titleMedium
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;

              final title = data['title'] ?? 'Notification';
              final message = data['message'] ?? '';
              final isRead = data['isRead'] ?? false;
              final timestamp = data['createdAt'] as Timestamp?;

              String timeAgo = '';
              if (timestamp != null) {
                final date = timestamp.toDate();
                timeAgo = DateFormat.yMMMd().add_jm().format(date);
              }

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isRead
                      ? AppColors.surface
                      : AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isRead
                        ? AppColors.border
                        : AppColors.primary.withOpacity(0.5),
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  onTap: () {
                    if (data['type'] == 'review_report' && data['reviewId'] != null) {
                      _showReviewManagementSheet(context, ref, data['reviewId'], doc.reference);
                    } else if (!isRead) {
                      // Mark as read in Firestore
                      doc.reference.update({'isRead': true});
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: isRead
                                ? AppColors.border.withOpacity(0.3)
                                : _getColorForType(data['type']).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Icon(
                              _getIconForType(data['type']),
                              color: isRead
                                  ? AppColors.textSecondary
                                  : _getColorForType(data['type']),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
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
                                style: AppTypography.bodySmall
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'new_booking':           return Icons.bookmark_added;
      case 'booking_accepted':      return Icons.check_circle_outline;
      case 'booking_rejected':      return Icons.cancel_outlined;
      case 'booking_completed':     return Icons.star_outline_rounded;
      case 'booking_ongoing':       return Icons.play_circle_outline;
      case 'booking_cancellation':
      case 'booking_cancelled':     return Icons.cancel_presentation;
      case 'payment_received':      return Icons.payments_outlined;
      case 'mystery_booking':
      case 'mystery_booked':        return Icons.card_giftcard;
      case 'mystery_revealed':      return Icons.lock_open_rounded;
      case 'mystery_booking_accepted':
      case 'mystery_accepted':      return Icons.card_giftcard;
      case 'mystery_booking_declined':
      case 'mystery_declined':      return Icons.block_outlined;
      case 'mystery_auto_declined': return Icons.timer_off_outlined;
      case 'review_report':         return Icons.report_problem_rounded;
      default:                      return Icons.notifications_outlined;
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
    // 1. Mark notification as read
    await notificationRef.update({'isRead': true});

    // 2. Fetch review details
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
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
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Reported Review Mitigation',
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'A guest has reported this review. As a host, you can choose to keep it or remove it from your experience.',
                style: AppTypography.bodyMediumSecondary,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Review Preview Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 20),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      message,
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        // Keep review: Just clear the report status
                        await FirebaseFirestore.instance
                            .collection('reviews')
                            .doc(reviewId)
                            .update({'isReported': false});
                        if (context.mounted) Navigator.pop(context);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Review kept. Report dismissed.')),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text('Keep Review', style: AppTypography.labelLarge),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Delete review
                        await ref.read(reviewRepositoryProvider).deleteReview(reviewId);
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
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text('Delete Review',
                          style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
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
