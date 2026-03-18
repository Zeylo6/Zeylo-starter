import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/booking_entity.dart';
import '../providers/booking_provider.dart';
import '../widgets/payment_card_input.dart';
import '../widgets/report_sheet.dart';
import '../../../../features/review/presentation/widgets/rate_and_review_sheet.dart';

/// Seeker Dashboard Screen — shows a seeker's bookings in 3 tabs
/// Responsive Layout implemented for Web
class SeekerDashboardScreen extends ConsumerStatefulWidget {
  const SeekerDashboardScreen({super.key});

  @override
  ConsumerState<SeekerDashboardScreen> createState() =>
      _SeekerDashboardScreenState();
}

class _SeekerDashboardScreenState extends ConsumerState<SeekerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Please log in to view your bookings.')),
          );
        }
        return _buildDashboard(context, user.uid);
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildDashboard(BuildContext context, String userId) {
    final bookingsAsync = ref.watch(userBookingsProvider(userId));
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: isDesktop ? null : IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Bookings',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Track all your experiences',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle:
              AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Ongoing'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          final upcoming = bookings
              .where((b) => b.status == 'pending' || b.status == 'confirmed')
              .toList();
          final ongoing = bookings.where((b) => b.status == 'ongoing').toList();
          final past = bookings
              .where((b) => b.status == 'completed' || b.status == 'cancelled')
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingList(context, upcoming, 'upcoming', userId, isDesktop),
              _buildBookingList(context, ongoing, 'ongoing', userId, isDesktop),
              _buildBookingList(context, past, 'past', userId, isDesktop),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text('Error loading bookings', style: AppTypography.bodyMedium),
              Text('$e',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingList(
    BuildContext context,
    List<BookingEntity> bookings,
    String type,
    String userId,
    bool isDesktop,
  ) {
    if (bookings.isEmpty) {
      final emojis = {'upcoming': '📅', 'ongoing': '🎯', 'past': '📖'};
      final messages = {
        'upcoming': 'No upcoming experiences',
        'ongoing': 'No ongoing experiences',
        'past': 'No past experiences yet',
      };
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emojis[type] ?? '📋', style: const TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.md),
            Text(
              messages[type] ?? 'No bookings',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              type == 'upcoming'
                  ? 'Browse experiences and book your next adventure!'
                  : 'Your experience history will appear here.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => ref.invalidate(userBookingsProvider(userId)),
      child: isDesktop 
      ? GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl, vertical: AppSpacing.xl),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400,
            crossAxisSpacing: AppSpacing.xl,
            mainAxisSpacing: AppSpacing.xl,
            childAspectRatio: 0.85, 
          ),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            return _BookingCard(
              booking: bookings[index],
              type: type,
              userId: userId,
              isDesktop: isDesktop,
              onPaymentComplete: () =>
                  ref.invalidate(userBookingsProvider(userId)),
            );
          },
        )
      : ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            return _BookingCard(
              booking: bookings[index],
              type: type,
              userId: userId,
              isDesktop: isDesktop,
              onPaymentComplete: () =>
                  ref.invalidate(userBookingsProvider(userId)),
            );
          },
        ),
    );
  }
}

/// Individual booking card widget
class _BookingCard extends ConsumerWidget {
  final BookingEntity booking;
  final String type;
  final String userId;
  final bool isDesktop;
  final VoidCallback onPaymentComplete;

  const _BookingCard({
    required this.booking,
    required this.type,
    required this.userId,
    required this.isDesktop,
    required this.onPaymentComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: isDesktop 
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ]
          : [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image + status badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
                child: booking.experienceCoverImage.isNotEmpty
                    ? Image.network(
                        booking.experienceCoverImage,
                        height: isDesktop ? 180 : 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderImage(),
                      )
                    : _placeholderImage(),
              ),
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: _StatusBadge(status: booking.status),
              ),
              if (type == 'ongoing' || type == 'past')
                Positioned(
                  bottom: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: GestureDetector(
                    onTap: () => _showReportSheet(context, ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.flag_rounded,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'Report',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.experienceTitle,
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        '${booking.date.day}/${booking.date.month}/${booking.date.year}  ${booking.startTime}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.group_rounded,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        '${booking.guests} guest${booking.guests > 1 ? 's' : ''}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Rs. ${booking.totalPrice.toStringAsFixed(0)}',
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
            
                  // Actions 
                  if (type == 'past' &&
                      booking.status == 'completed' &&
                      !booking.isRatedBySeeker) ...[
                    ZeyloButton(
                      onPressed: () {
                         _showReviewDialogOrSheet(context, ref);
                      },
                      label: 'Rate Experience',
                      variant: ButtonVariant.filled,
                      icon: const Icon(Icons.star_rounded,
                          size: 20, color: Colors.white),
                    ),
                  ],
            
                  // Complete & Pay button 
                  if (type == 'ongoing') ...[
                    if (booking.paymentStatus != 'paid')
                      ZeyloButton(
                        onPressed: () => _showPaymentSheet(context),
                        label: '💳  Complete & Pay',
                        variant: ButtonVariant.filled,
                      )
                    else
                      ZeyloButton(
                        onPressed: () => _completeExperience(context, ref),
                        label: '✅  Complete Experience',
                        variant: ButtonVariant.filled,
                        backgroundColor: AppColors.success,
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: isDesktop ? 180 : 160,
      width: double.infinity,
      color: AppColors.surface,
      child: const Icon(
        Icons.image_not_supported,
        size: 48,
        color: AppColors.textSecondary,
      ),
    );
  }

  void _showReviewDialogOrSheet(BuildContext context, WidgetRef ref) {
    if (isDesktop) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          child: Container(
             width: 500,
             constraints: const BoxConstraints(maxHeight: 700),
             padding: const EdgeInsets.all(AppSpacing.md),
             child: RateAndReviewSheet(
                booking: booking,
                reviewerRole: 'seeker',
                onSuccess: () {
                  Navigator.pop(context); // Close dialog explicitly here
                  onPaymentComplete(); 
                },
             ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => RateAndReviewSheet(
          booking: booking,
          reviewerRole: 'seeker',
          onSuccess: onPaymentComplete,
        ),
      );
    }
  }

  void _showPaymentSheet(BuildContext context) {
    if (isDesktop) {
       showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          child: SizedBox(
             width: 500,
             height: 600,
             child: _PaymentSheet(
                booking: booking,
                onSuccess: onPaymentComplete,
             ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _PaymentSheet(
          booking: booking,
          onSuccess: onPaymentComplete,
        ),
      );
    }
  }

  void _showReportSheet(BuildContext context, WidgetRef ref) {
    if (isDesktop) {
       showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          child: SizedBox(
             width: 500,
             height: 480,
             child: ReportSheet(
                reportedUserId: booking.hostId, // Seeker is reporting the Host
                bookingId: booking.id,
                reporterRole: 'seeker',
                reportedRole: 'host',
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
          reportedUserId: booking.hostId, 
          bookingId: booking.id,
          reporterRole: 'seeker',
          reportedRole: 'host',
        ),
      );
    }
  }

  Future<void> _completeExperience(BuildContext context, WidgetRef ref) async {
    try {
      final db = FirebaseFirestore.instance;
      await db.collection('bookings').doc(booking.id).update({
        'status': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        onPaymentComplete(); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Experience marked as completed! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete experience: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Status badge widget
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = {
      'pending': {'color': const Color(0xFFF59E0B), 'label': 'Pending'},
      'confirmed': {'color': const Color(0xFF10B981), 'label': 'Confirmed'},
      'ongoing': {'color': const Color(0xFF6C63FF), 'label': 'Ongoing'},
      'completed': {'color': const Color(0xFF059669), 'label': 'Completed'},
      'cancelled': {'color': const Color(0xFFEF4444), 'label': 'Cancelled'},
    };
    final c = config[status] ?? config['pending']!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (c['color'] as Color).withAlpha(220),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        c['label'] as String,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Payment bottom sheet / Dialog
class _PaymentSheet extends StatefulWidget {
  final BookingEntity booking;
  final VoidCallback onSuccess;

  const _PaymentSheet({required this.booking, required this.onSuccess});

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  bool _isProcessing = false;
  String _cardNumber = '';
  String _expiry = '';
  String _cvc = '';
  String _cardholderName = '';

  bool get _isFormValid =>
      _cardNumber.replaceAll(' ', '').length == 16 &&
      _expiry.length == 5 &&
      _cvc.length >= 3 &&
      _cardholderName.trim().isNotEmpty;

  Future<void> _processPayment() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all card details correctly.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      final db = FirebaseFirestore.instance;
      final batch = db.batch();
      final bookingRef = db.collection('bookings').doc(widget.booking.id);
      batch.update(bookingRef, {
        'status': 'completed',
        'paymentStatus': 'paid',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final activityRef = db.collection('activities').doc();
      batch.set(activityRef, {
        'userId': widget.booking.hostId, 
        'title': 'Payment Received! 💰',
        'message':
            'A seeker has completed the payment for "${widget.booking.experienceTitle}".',
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'payment_received',
        'isRead': false,
        'bookingId': widget.booking.id,
      });

      await batch.commit();

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Payment successful! Experience completed. 🎉'),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    
    // Core payment UI contents 
    Widget content = ListView(
      physics: isDesktop ? const BouncingScrollPhysics() : const ClampingScrollPhysics(),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: isDesktop ? AppSpacing.xl : AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      children: [
        if (!isDesktop) // Handle bar only for mobile sheet
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
        if (!isDesktop) const SizedBox(height: AppSpacing.md),

        // Header
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                   BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                ]
              ),
              child: const Icon(Icons.payment_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete Payment',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    widget.booking.experienceTitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isDesktop) 
             IconButton(
               icon: const Icon(Icons.close_rounded),
               onPressed: () => Navigator.pop(context),
             ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Order summary
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _summaryRow('Experience', widget.booking.experienceTitle,
                  bold: false),
              const Divider(height: AppSpacing.lg),
              _summaryRow('Guests', '${widget.booking.guests} person(s)'),
              const SizedBox(height: 4),
              _summaryRow('Date',
                  '${widget.booking.date.day}/${widget.booking.date.month}/${widget.booking.date.year}'),
              const Divider(height: AppSpacing.lg),
              _summaryRow(
                'Total Amount',
                'Rs. ${widget.booking.totalPrice.toStringAsFixed(0)}',
                bold: true,
                highlight: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        Text(
          'Card Details',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        PaymentCardInput(
          onCardNumberChanged: (v) => setState(() => _cardNumber = v),
          onExpiryChanged: (v) => setState(() => _expiry = v),
          onCVCChanged: (v) => setState(() => _cvc = v),
          onCardholderNameChanged: (v) =>
              setState(() => _cardholderName = v),
        ),
        const SizedBox(height: AppSpacing.xxl),

        ZeyloButton(
          onPressed: _isProcessing ? null : _processPayment,
          label: _isProcessing
              ? 'Processing Securely...'
              : 'Pay Rs. ${widget.booking.totalPrice.toStringAsFixed(0)}',
          isLoading: _isProcessing,
          variant: ButtonVariant.filled,
          height: 56,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_rounded,
                size: 14, color: AppColors.success),
            const SizedBox(width: 6),
            Text(
              'Payments are 256-bit encrypted & secure',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );

    if (isDesktop) {
       return ClipRRect(
         borderRadius: BorderRadius.circular(AppRadius.xl),
         child: Material(
           color: AppColors.background,
           child: content,
         ),
       );
    } // else Mobile
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: content,
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool bold = false, bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: bold
                ? AppTypography.titleLarge.copyWith(
                    color: highlight ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  )
                : AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
