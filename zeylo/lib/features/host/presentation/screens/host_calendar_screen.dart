import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';

/// Host Calendar Screen
/// Desktop uses a horizontal Row view to expand TableCalendar and Agenda.
class HostCalendarScreen extends ConsumerStatefulWidget {
  const HostCalendarScreen({super.key});

  @override
  ConsumerState<HostCalendarScreen> createState() => _HostCalendarScreenState();
}

class _HostCalendarScreenState extends ConsumerState<HostCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Map of date (stripped of time) to list of bookings
  Map<DateTime, List<Map<String, dynamic>>> _bookingsByDate = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('hostId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'confirmed')
          .get();

      final newMap = <DateTime, List<Map<String, dynamic>>>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id; // Inject id for cancellation logic
        if (data['date'] is Timestamp) {
          final date = (data['date'] as Timestamp).toDate();
          final day = DateTime(date.year, date.month, date.day);

          if (newMap[day] == null) {
            newMap[day] = [];
          }
          newMap[day]!.add(data);
        }
      }

      // Fetch Blocked Dates
      final blockedSnapshot = await FirebaseFirestore.instance
          .collection('calendar_blocks')
          .where('hostId', isEqualTo: user.uid)
          .get();

      for (var doc in blockedSnapshot.docs) {
        final data = doc.data();
        if (data['date'] is Timestamp) {
          final date = (data['date'] as Timestamp).toDate();
          final day = DateTime(date.year, date.month, date.day);

          if (newMap[day] == null) {
            newMap[day] = [];
          }
          newMap[day]!.add({
            'isBlock': true,
            'experienceTitle': 'Blocked Date',
            'blockId': doc.id,
          });
        }
      }

      if (mounted) {
        setState(() {
          _bookingsByDate = newMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching calendar bookings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    // Normalize to midnight
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _bookingsByDate[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    final calendarWidget = Container(
      padding: const EdgeInsets.only(bottom: AppSpacing.md, top: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: isDesktop ? null : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          }
        },
        eventLoader: _getEventsForDay,
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
          ),
          todayTextStyle: AppTypography.labelMedium.copyWith(color: AppColors.primary),
          selectedDecoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, Color(0xFF8E2DE2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryAlpha30,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          selectedTextStyle: AppTypography.labelMedium.copyWith(color: Colors.white),
          markerDecoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
          markerSize: 4.0,
          markersMaxCount: 1,
          markerMargin: const EdgeInsets.only(top: 6),
          outsideDaysVisible: false,
          weekendTextStyle: AppTypography.bodyMediumSecondary,
          defaultTextStyle: AppTypography.bodyMedium,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
          leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary),
          rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTypography.labelSmall.copyWith(color: AppColors.textHint),
          weekendStyle: AppTypography.labelSmall.copyWith(color: AppColors.textHint),
        ),
      ),
    );

    final eventsWidget = selectedEvents.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No bookings on this day.',
                  style: AppTypography.bodyMediumSecondary,
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton.icon(
                  onPressed: () => _blockSelectedDate(),
                  icon: const Icon(Icons.block, size: 18),
                  label: const Text('Block Date'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.textInverse,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: selectedEvents.length,
            itemBuilder: (context, index) {
              final exp = selectedEvents[index];
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exp['experienceTitle'] ?? 'Experience',
                      style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (exp['isBlock'] == true) ...[
                      Text('You have blocked this date.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.error)),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: () => _unblockDate(exp['blockId']),
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 25)),
                        child: const Text('Unblock'),
                      ),
                    ] else ...[
                      Row(
                         children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('${exp['startTime'] ?? 'TBA'}', style: AppTypography.bodySmall),
                         ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                         children: [
                            const Icon(Icons.people_outline_rounded, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('${exp['guests'] ?? 1} Guests', style: AppTypography.bodySmall),
                         ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                         children: [
                            const Icon(Icons.payments_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('Rs. ${exp['totalPrice'] ?? 0}', style: AppTypography.bodySmall),
                         ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (exp['status'] != 'cancelled_by_host')
                        TextButton(
                          onPressed: () => _cancelBooking(exp),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(50, 25),
                            alignment: Alignment.centerLeft,
                          ),
                          child: const Text('Cancel Booking', style: TextStyle(fontWeight: FontWeight.w600)),
                        )
                      else
                        Text('Cancelled',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
              );
            },
          );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Booking Calendar', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (isDesktop 
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Expanded(flex: 5, child: SingleChildScrollView(child: calendarWidget)),
                     Container(width: 1, color: AppColors.border),
                     Expanded(flex: 4, child: Container(color: AppColors.surfaceContainerLow, child: eventsWidget)),
                  ],
                )
              : Column(
                  children: [
                    calendarWidget,
                    Expanded(child: eventsWidget),
                  ],
                )
            ),
    );
  }

  Future<void> _blockSelectedDate() async {
    if (_selectedDay == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('calendar_blocks').add({
        'hostId': user.uid,
        'date': Timestamp.fromDate(_selectedDay!),
        'createdAt': FieldValue.serverTimestamp(),
      });
      _fetchBookings(); // Refresh visually
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Date blocked.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error blocking date: $e')));
      }
    }
  }

  Future<void> _unblockDate(String blockId) async {
    try {
      await FirebaseFirestore.instance
          .collection('calendar_blocks')
          .doc(blockId)
          .delete();
      _fetchBookings(); // Refresh visually
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Date unblocked.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error unblocking date: $e')));
      }
    }
  }

  Future<void> _cancelBooking(Map<String, dynamic> booking) async {
    final bookingId = booking['id'];
    if (bookingId == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Booking'),
        content: const Text(
            'Are you sure you want to cancel this booking? The seeker will be notified.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                // Update booking status
                await FirebaseFirestore.instance
                    .collection('bookings')
                    .doc(bookingId)
                    .update({
                  'status': 'cancelled_by_host',
                });

                // Send notification to seeker
                await FirebaseFirestore.instance.collection('activities').add({
                  'userId': booking['userId'], // target the seeker
                  'title': 'Booking Cancelled',
                  'message':
                      'The host has cancelled your booking for ${booking['experienceTitle'] ?? 'an experience'}.',
                  'createdAt': FieldValue.serverTimestamp(),
                  'type': 'booking_cancellation',
                  'isRead': false,
                });

                // Refresh calendar locally
                _fetchBookings();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Booking cancelled.'), backgroundColor: AppColors.error));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to cancel: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }
}
