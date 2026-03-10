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

/// Seeker Dashboard Screen — shows a seeker's bookings in 3 tabs
class SeekerDashboardScreen extends ConsumerStatefulWidget {
  const SeekerDashboardScreen({super.key});

  @override
  ConsumerState<SeekerDashboardScreen> createState() =>
      _SeekerDashboardScreenState();
}

class _SeekerDashboardScreenState
    extends ConsumerState<SeekerDashboardScreen>
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
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildDashboard(BuildContext context, String userId) {
    final bookingsAsync = ref.watch(userBookingsProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
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
          labelStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
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
          final ongoing = bookings
              .where((b) => b.status == 'ongoing')
              .toList();
          final past = bookings
              .where((b) => b.status == 'completed' || b.status == 'cancelled')
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingList(context, upcoming, 'upcoming', userId),
              _buildBookingList(context, ongoing, 'ongoing', userId),
              _buildBookingList(context, past, 'past', userId),
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
              Text('$e', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
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
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return _BookingCard(
            booking: bookings[index],
            type: type,
            userId: userId,
            onPaymentComplete: () => ref.invalidate(userBookingsProvider(userId)),
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
  final VoidCallback onPaymentComplete;

  const _BookingCard({
    required this.booking,
    required this.type,
    required this.userId,
    required this.onPaymentComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 12,
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
                        height: 160,
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
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.experienceTitle,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${booking.date.day}/${booking.date.month}/${booking.date.year}  ${booking.startTime}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.group, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${booking.guests} guest${booking.guests > 1 ? 's' : ''}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${booking.totalPrice.toStringAsFixed(2)}',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                // Payment status chip
                if (booking.paymentStatus == 'paid') ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(25),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 14, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          'Payment Confirmed',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Complete & Pay button (only for ongoing bookings)
                if (type == 'ongoing' && booking.paymentStatus != 'paid') ...[
                  const SizedBox(height: AppSpacing.md),
                  ZeyloButton(
                    onPressed: () => _showPaymentSheet(context),
                    label: '💳  Complete & Pay',
                    variant: ButtonVariant.filled,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 160,
      width: double.infinity,
      color: AppColors.surface,
      child: const Icon(
        Icons.image_not_supported,
        size: 48,
        color: AppColors.textSecondary,
      ),
    );
  }

  void _showPaymentSheet(BuildContext context) {
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

/// Status badge widget
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = {
      'pending':   {'color': const Color(0xFFF59E0B), 'label': 'Pending'},
      'confirmed': {'color': const Color(0xFF10B981), 'label': 'Confirmed'},
      'ongoing':   {'color': const Color(0xFF6C63FF), 'label': 'Ongoing'},
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

/// Payment bottom sheet
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
      // Simulate payment processing delay (replace with real payment gateway)
      await Future.delayed(const Duration(seconds: 2));

      // Update Firestore
      final db = FirebaseFirestore.instance;
      final batch = db.batch();
      final bookingRef = db.collection('bookings').doc(widget.booking.id);
      batch.update(bookingRef, {
        'status': 'completed',
        'paymentStatus': 'paid',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notify the host
      final activityRef = db.collection('activities').doc();
      batch.set(activityRef, {
        'userId': widget.booking.hostId, // The recipient is the host
        'title': 'Payment Received! 💰',
        'message': 'A seeker has completed the payment for "${widget.booking.experienceTitle}".',
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
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: ListView(
          controller: controller,
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.sm,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
          ),
          children: [
            // Handle bar
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
            const SizedBox(height: AppSpacing.md),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.payment, color: Colors.white, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
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
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

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
                  _summaryRow('Experience', widget.booking.experienceTitle, bold: false),
                  const Divider(height: AppSpacing.lg),
                  _summaryRow('Guests', '${widget.booking.guests} person(s)'),
                  const SizedBox(height: 4),
                  _summaryRow('Date', '${widget.booking.date.day}/${widget.booking.date.month}/${widget.booking.date.year}'),
                  const Divider(height: AppSpacing.lg),
                  _summaryRow(
                    'Total Amount',
                    '\$${widget.booking.totalPrice.toStringAsFixed(2)}',
                    bold: true,
                    highlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(
              'Card Details',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            PaymentCardInput(
              onCardNumberChanged: (v) => setState(() => _cardNumber = v),
              onExpiryChanged: (v) => setState(() => _expiry = v),
              onCVCChanged: (v) => setState(() => _cvc = v),
              onCardholderNameChanged: (v) => setState(() => _cardholderName = v),
            ),
            const SizedBox(height: AppSpacing.xl),

            ZeyloButton(
              onPressed: _isProcessing ? null : _processPayment,
              label: _isProcessing
                  ? 'Processing...'
                  : 'Pay \$${widget.booking.totalPrice.toStringAsFixed(2)}',
              isLoading: _isProcessing,
              variant: ButtonVariant.filled,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Payments are encrypted & secure',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false, bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: bold
              ? AppTypography.titleMedium.copyWith(
                  color: highlight ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                )
              : AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
