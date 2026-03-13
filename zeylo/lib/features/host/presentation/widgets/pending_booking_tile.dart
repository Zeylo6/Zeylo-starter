import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
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
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
              Expanded(
                child: Text(
                  booking['experienceTitle'] ?? 'Experience',
                  style: AppTypography.labelLarge
                      .copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'Pending',
                  style: AppTypography.labelSmall.copyWith(
                      color: Colors.orange[800], fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              _SeekerAvatar(
                userId: booking['userId'] ?? '',
                initialPhotoUrl: booking['seekerPhotoUrl'] ?? booking['seeker_photo_url'],
                radius: 10,
              ),
              const SizedBox(width: 6),
              _SeekerNameText(
                userId: booking['userId'] ?? '',
                initialName: booking['seekerName'] ?? booking['seeker_name'],
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$formattedDate at ${booking['startTime'] ?? ''}',
            style: AppTypography.bodySmall,
          ),
          Text(
            'Guests: ${booking['guests'] ?? 1} • Total: \$${booking['totalPrice'] ?? 0}',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm)),
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm)),
                  ),
                  child: const Text('Accept'),
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
