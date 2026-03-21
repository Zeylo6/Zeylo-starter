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
import '../widgets/payment_card_input.dart';
import '../widgets/report_sheet.dart';
import '../../../../features/review/presentation/widgets/rate_and_review_sheet.dart';
import '../../../../core/services/stripe_payment_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STATUS DEFINITIONS
//
// UPCOMING  : Bookings that have been made but the experience hasn't started yet.
//             Statuses: pending, confirmed, mystery_pending, mystery_revealed, mystery_accepted
//
// ONGOING   : The experience is currently happening (start time reached, not yet ended).
//             Status: ongoing
//
// PAST      : Experience has finished or booking was cancelled/declined.
//             Statuses: completed, cancelled, mystery_declined
// ─────────────────────────────────────────────────────────────────────────────

class SeekerDashboardScreen extends ConsumerStatefulWidget {
  const SeekerDashboardScreen({super.key});

  @override
  ConsumerState<SeekerDashboardScreen> createState() =>
      _SeekerDashboardScreenState();
}

class _SeekerDashboardScreenState extends ConsumerState<SeekerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Stream<QuerySnapshot>? _bookingsStream;
  String? _currentUserId;

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

  Stream<QuerySnapshot> _getStream(String userId) {
    // Only create a new stream if userId changed — keeps stream stable
    if (_currentUserId != userId || _bookingsStream == null) {
      _currentUserId = userId;
      _bookingsStream = FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .snapshots();
    }
    return _bookingsStream!;
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
    final bookingsStream = _getStream(userId);

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
          labelStyle:
              AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Ongoing'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: AppSpacing.md),
                  Text('Error loading bookings',
                      style: AppTypography.bodyMedium),
                ],
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final allBookings = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return BookingEntity(
              id: doc.id,
              experienceId: data['experienceId'] as String? ?? '',
              experienceTitle: data['experienceTitle'] as String? ?? '',
              experienceCoverImage:
                  data['experienceCoverImage'] as String? ?? '',
              userId: data['userId'] as String? ?? '',
              hostId: data['hostId'] as String? ?? '',
              date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
              startTime: data['startTime'] as String? ?? '09:00 AM',
              guests: data['guests'] as int? ?? 1,
              totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
              status: data['status'] as String? ?? 'pending',
              paymentStatus: data['paymentStatus'] as String? ?? 'pending',
              createdAt:
                  (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              updatedAt:
                  (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              isRatedByHost: data['isRatedByHost'] as bool? ?? false,
              isRatedBySeeker: data['isRatedBySeeker'] as bool? ?? false,
              seekerName: data['seekerName'] as String?,
              seekerPhotoUrl: data['seekerPhotoUrl'] as String?,
              isEarningsCollected: data['isEarningsCollected'] as bool? ?? false,
              isMystery: data['isMystery'] == true ||
                  data['isMystery'] == 'true',
              mysteryId: data['mysteryId'] as String?,
            );
          }).toList();

          // Sort newest first
          allBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          // ── UPCOMING: booked but not yet started ──────────────────────────
          // Includes: pending, accepted, confirmed, mystery_pending, mystery_revealed, mystery_accepted
          final upcoming = allBookings.where((b) {
            return b.status == 'pending' ||
                b.status == 'accepted' ||
                b.status == 'confirmed' ||
                b.status == 'mystery_pending' ||
                b.status == 'mystery_revealed' ||
                b.status == 'mystery_accepted';
          }).toList();

          // ── ONGOING: experience is currently happening ────────────────────
          final ongoing =
              allBookings.where((b) => b.status == 'ongoing').toList();

          // ── PAST: finished or cancelled ───────────────────────────────────
          final past = allBookings.where((b) {
            return b.status == 'completed' ||
                b.status == 'cancelled' ||
                b.status == 'mystery_declined' ||
                b.status == 'rejected';
          }).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingList(context, upcoming, 'upcoming', userId),
              _buildBookingList(context, ongoing, 'ongoing', userId),
              _buildBookingList(context, past, 'past', userId),
            ],
          );
        },
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
      final subtitles = {
        'upcoming': 'Browse experiences and book your next adventure!',
        'ongoing': 'Your active experiences will appear here.',
        'past': 'Your experience history will appear here.',
      };

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emojis[type] ?? '📋',
                style: const TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.md),
            Text(
              messages[type] ?? 'No bookings',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                subtitles[type] ?? '',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return _BookingCard(
          booking: bookings[index],
          type: type,
          userId: userId,
          onRefresh: () {
            // Stream-based — no manual refresh needed, but keep callback
            // for snackbar purposes
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOOKING CARD
// ─────────────────────────────────────────────────────────────────────────────

class _BookingCard extends ConsumerWidget {
  final BookingEntity booking;
  final String type;
  final String userId;
  final VoidCallback onRefresh;

  const _BookingCard({
    required this.booking,
    required this.type,
    required this.userId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (booking.isMystery) {
      return _buildMysteryCard(context, ref);
    }
    return _buildNormalCard(context, ref);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // MYSTERY CARD LOGIC
  // Status flow:
  //   mystery_pending   → masked (no details shown, countdown to 48hrs before)
  //   mystery_revealed  → show details + accept / decline buttons
  //   mystery_accepted  → show as normal card (it's in upcoming)
  //   mystery_declined  → shown in Past tab
  // ──────────────────────────────────────────────────────────────────────────

  DateTime _getExperienceDateTime(BookingEntity booking) {
    int hour = 9;
    int minute = 0;
    try {
      final timeParts = booking.startTime.split(' ');
      final hm = timeParts[0].split(':');
      hour = int.parse(hm[0]);
      minute = int.parse(hm[1]);
      if (timeParts.length > 1 && timeParts[1].toUpperCase() == 'PM' && hour < 12) {
        hour += 12;
      }
      if (timeParts.length > 1 && timeParts[1].toUpperCase() == 'AM' && hour == 12) {
        hour = 0;
      }
    } catch (_) {}

    return DateTime(
      booking.date.year,
      booking.date.month,
      booking.date.day,
      hour,
      minute,
    );
  }

  Widget _buildMysteryCard(BuildContext context, WidgetRef ref) {
    if (booking.status == 'mystery_accepted' || 
        booking.status == 'pending' || 
        booking.status == 'accepted' || 
        booking.status == 'confirmed') {
      return _buildNormalCard(context, ref);
    }
    if (booking.status == 'mystery_declined' || booking.status == 'rejected' || booking.status == 'cancelled') {
      return _buildDeclinedMysteryCard();
    }

    final experienceDateTime = _getExperienceDateTime(booking);
    // Reveal 48 hours before
    final isRevealed = experienceDateTime.difference(DateTime.now()).inHours <= 48;

    if (!isRevealed && booking.status != 'mystery_revealed') {
      return _buildMaskedMysteryCard();
    } else {
      return _buildRevealedMysteryCard(context, ref);
    }
  }

  /// Masked mystery card — shown in Upcoming for ALL mystery bookings
  /// until status becomes "mystery_revealed".
  /// NEVER shows experience name, image, or any identifying details.
  Widget _buildMaskedMysteryCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top mystery image area ────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2D1B69),
                    Color(0xFF6D28D9),
                    Color(0xFFA855F7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Subtle pattern overlay
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.08,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                        ),
                        itemCount: 64,
                        itemBuilder: (_, __) => const Icon(
                          Icons.question_mark,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  // Centre lock + label
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Mystery Experience',
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Details hidden until reveal',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Mystery badge — top right
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🎁',
                              style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),
                          Text(
                            'Mystery',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Card body ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Mystery Adventure 🎁',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'A perfect experience has been secretly matched for you.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Date + guests row
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${booking.date.day}/${booking.date.month}/${booking.date.year}   ${booking.startTime}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.group,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${booking.guests} guest${booking.guests > 1 ? "s" : ""}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Rs. ${booking.totalPrice.toStringAsFixed(0)}',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Reveal countdown banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.08),
                        AppColors.primary.withOpacity(0.04),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final expDateTime = _getExperienceDateTime(booking);
                            final difference = expDateTime.subtract(const Duration(hours: 48)).difference(DateTime.now());
                            if (difference.isNegative) {
                              return Text(
                                'Revealing shortly...',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              );
                            }
                            final displayDays = difference.inDays > 0 ? '${difference.inDays}d ' : '';
                            final displayHours = difference.inHours % 24;
                            final displayMins = difference.inMinutes % 60;
                            final countdownStr = "$displayDays${displayHours}h ${displayMins}m";
                            return Text(
                              'Reveals in: $countdownStr',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Revealed card — shown when 48 hour threshold is met!
  Widget _buildRevealedMysteryCard(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        boxShadow: [
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
          // Revealed banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.card_giftcard,
                    color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Mystery Revealed! Your adventure awaits 🎁',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Cover image
          if (booking.experienceCoverImage.isNotEmpty)
            ClipRRect(
              child: Image.network(
                booking.experienceCoverImage,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _imagePlaceholder(),
              ),
            )
          else
            _imagePlaceholder(),

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
                ),
                const SizedBox(height: AppSpacing.sm),
                _infoRow(
                    Icons.calendar_today,
                    '${booking.date.day}/${booking.date.month}/${booking.date.year}  ${booking.startTime}'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _infoRow(Icons.group,
                        '${booking.guests} guest${booking.guests > 1 ? 's' : ''}'),
                    const Spacer(),
                    Text(
                      'Rs. ${booking.totalPrice.toStringAsFixed(0)}',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Accept / Decline deadline note
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                        color: AppColors.warning.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 16, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Accept or decline before 24 hours prior to the experience.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ZeyloButton(
                        label: 'Accept',
                        variant: ButtonVariant.filled,
                        backgroundColor: AppColors.success,
                        onPressed: () =>
                            _acceptMystery(context, ref),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ZeyloButton(
                        label: 'Decline',
                        variant: ButtonVariant.outlined,
                        onPressed: () =>
                            _declineMystery(context, ref),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeclinedMysteryCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cancel_outlined,
                color: AppColors.error, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mystery Declined',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking.date.day}/${booking.date.month}/${booking.date.year}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // NORMAL CARD
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildNormalCard(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 30,
            offset: const Offset(0, 8),
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
                        errorBuilder: (_, __, ___) =>
                            _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
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
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
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
                _infoRow(
                    Icons.calendar_today,
                    '${booking.date.day}/${booking.date.month}/${booking.date.year}  ${booking.startTime}'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _infoRow(Icons.group,
                        '${booking.guests} guest${booking.guests > 1 ? 's' : ''}'),
                    const Spacer(),
                    Text(
                      'Rs. ${booking.totalPrice.toStringAsFixed(0)}',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                // Rate Now (past + completed + unrated)
                if (type == 'past' &&
                    booking.status == 'completed' &&
                    !booking.isRatedBySeeker) ...[
                  const SizedBox(height: AppSpacing.md),
                  ZeyloButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => RateAndReviewSheet(
                          booking: booking,
                          reviewerRole: 'seeker',
                          onSuccess: onRefresh,
                        ),
                      );
                    },
                    label: 'Rate Experience',
                    variant: ButtonVariant.filled,
                    icon: const Icon(Icons.star_rounded,
                        size: 20, color: Colors.white),
                  ),
                ],

                // Ongoing actions
                if (type == 'ongoing') ...[
                  const SizedBox(height: AppSpacing.md),
                  if (booking.paymentStatus != 'paid')
                    ZeyloButton(
                      onPressed: () => _showPaymentSheet(context),
                      label: '💳  Complete & Pay',
                      variant: ButtonVariant.filled,
                    )
                  else
                    ZeyloButton(
                      onPressed: () =>
                          _completeExperience(context, ref),
                      label: '✅  Mark Complete',
                      variant: ButtonVariant.filled,
                      backgroundColor: AppColors.success,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ACTIONS
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _acceptMystery(BuildContext context, WidgetRef ref) async {
    try {
      // 1. Trigger Stripe Payment
      final user = FirebaseAuth.instance.currentUser;
      final paymentId = await StripePaymentService.makePayment(
        booking.totalPrice,
        booking.id, // using booking.id for payment intent bookingId
        user?.email ?? '',
        type: 'mystery',
        mysteryId: booking.mysteryId,
      );

      // 2. Accept Mystery only after successful payment
      final db = FirebaseFirestore.instance;
      final batch = db.batch();

      batch.update(db.collection('bookings').doc(booking.id), {
        'status': 'pending', // Making it 'pending' brings it to the Host Dashboard
        'paymentStatus': 'paid',
        'paymentId': paymentId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (booking.mysteryId != null) {
        batch.update(db.collection('mysteries').doc(booking.mysteryId), {
          'status': 'accepted',
        });
      }

      await batch.commit();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mystery experience accepted & paid! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _declineMystery(BuildContext context, WidgetRef ref) async {
    try {
      final db = FirebaseFirestore.instance;
      final batch = db.batch();

      batch.update(db.collection('bookings').doc(booking.id), {
        'status': 'mystery_declined',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (booking.mysteryId != null) {
        batch.update(db.collection('mysteries').doc(booking.mysteryId), {
          'status': 'declined',
        });
      }

      await batch.commit();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mystery experience declined.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to decline: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showPaymentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentSheet(
        booking: booking,
        onSuccess: onRefresh,
      ),
    );
  }

  void _showReportSheet(BuildContext context, WidgetRef ref) {
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

  Future<void> _completeExperience(
      BuildContext context, WidgetRef ref) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(booking.id)
          .update({
        'status': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        onRefresh();
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
            content: Text('Failed to complete: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  Widget _imagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color: AppColors.surface,
      child: const Icon(Icons.image_outlined,
          color: AppColors.textHint, size: 40),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS BADGE
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = <String, Map<String, dynamic>>{
      'pending': {'color': const Color(0xFF6C63FF), 'label': 'Upcoming'},
      'confirmed': {'color': const Color(0xFF10B981), 'label': 'Confirmed'},
      'ongoing': {'color': const Color(0xFF6C63FF), 'label': 'Ongoing'},
      'completed': {'color': const Color(0xFF059669), 'label': 'Completed'},
      'cancelled': {'color': const Color(0xFFEF4444), 'label': 'Cancelled'},
      'mystery_pending': {
        'color': const Color(0xFF8B5CF6),
        'label': 'Mystery 🎁',
      },
      'mystery_revealed': {
        'color': const Color(0xFFF59E0B),
        'label': 'Revealed! 🎁',
      },
      'mystery_accepted': {
        'color': const Color(0xFF10B981),
        'label': 'Accepted',
      },
      'mystery_declined': {
        'color': const Color(0xFFEF4444),
        'label': 'Declined',
      },
    };

    final c = config[status] ?? config['pending']!;
    final color = c['color'] as Color;
    final label = c['label'] as String;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(220),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
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

// ─────────────────────────────────────────────────────────────────────────────
// PAYMENT SHEET
// ─────────────────────────────────────────────────────────────────────────────

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

      batch.update(db.collection('bookings').doc(widget.booking.id), {
        'paymentStatus': 'paid',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final activityRef = db.collection('activities').doc();
      batch.set(activityRef, {
        'userId': widget.booking.hostId,
        'title': 'Payment Received! 💰',
        'message':
            'A seeker completed payment for "${widget.booking.experienceTitle}".',
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
          const SnackBar(
            content: Row(children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Payment successful! 🎉'),
            ]),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
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
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
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
            Text(
              'Complete Payment',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.booking.experienceTitle,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _row('Guests', '${widget.booking.guests} person(s)'),
                  const SizedBox(height: 4),
                  _row(
                      'Date',
                      '${widget.booking.date.day}/${widget.booking.date.month}/${widget.booking.date.year}'),
                  const Divider(height: AppSpacing.lg),
                  _row(
                    'Total',
                    'Rs. ${widget.booking.totalPrice.toStringAsFixed(0)}',
                    highlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            PaymentCardInput(
              onCardNumberChanged: (v) => setState(() => _cardNumber = v),
              onExpiryChanged: (v) => setState(() => _expiry = v),
              onCVCChanged: (v) => setState(() => _cvc = v),
              onCardholderNameChanged: (v) =>
                  setState(() => _cardholderName = v),
            ),
            const SizedBox(height: AppSpacing.xl),
            ZeyloButton(
              onPressed: _isProcessing ? null : _processPayment,
              label: _isProcessing
                  ? 'Processing...'
                  : 'Pay Rs. ${widget.booking.totalPrice.toStringAsFixed(0)}',
              isLoading: _isProcessing,
              variant: ButtonVariant.filled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textSecondary)),
        Text(
          value,
          style: highlight
              ? AppTypography.titleMedium.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w800)
              : AppTypography.bodySmall
                  .copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}