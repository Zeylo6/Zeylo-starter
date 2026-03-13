import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:intl/intl.dart';

class PendingBookingTile extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const PendingBookingTile({
    required this.booking,
    required this.onAccept,
    required this.onReject,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = 'Unknown Date';
    if (booking['date'] != null && booking['date'] is Timestamp) {
      formattedDate = DateFormat('MMM d, yyyy')
          .format((booking['date'] as Timestamp).toDate());
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  booking['experienceTitle'] ?? 'Experience',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Pending Request',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SeekerAvatar(
                userId: booking['userId'] ?? '',
                initialPhotoUrl: booking['seekerPhotoUrl'] ?? booking['seeker_photo_url'],
                radius: 12,
              ),
              const SizedBox(width: 8),
              _SeekerNameText(
                userId: booking['userId'] ?? '',
                initialName: booking['seekerName'] ?? booking['seeker_name'],
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(formattedDate, style: AppTypography.bodySmallSecondary),
              const SizedBox(width: 12),
              const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(booking['startTime'] ?? '', style: AppTypography.bodySmallSecondary),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.people_outline, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text('${booking['guests'] ?? 1} Guests', style: AppTypography.bodySmallSecondary),
              const Spacer(),
              Text(
                'LKR ${booking['totalPrice'] ?? 0}',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onReject,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppColors.error.withOpacity(0.2)),
                    ),
                  ),
                  child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981), // Modern Green
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
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
        backgroundColor: AppColors.divider,
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
          backgroundColor: AppColors.divider,
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
