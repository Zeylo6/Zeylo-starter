import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/config/app_config.dart';

class AdminExperienceDetailSheet extends StatefulWidget {
  final String experienceId;
  final Map<String, dynamic> data;

  const AdminExperienceDetailSheet({
    required this.experienceId,
    required this.data,
    super.key,
  });

  @override
  State<AdminExperienceDetailSheet> createState() =>
      _AdminExperienceDetailSheetState();
}

class _AdminExperienceDetailSheetState
    extends State<AdminExperienceDetailSheet> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.data['title'] ?? 'Untitled';
    final desc = widget.data['description'] ?? 'No Description provided.';
    final hostName = widget.data['hostName'] ?? 'Unknown Host';
    final hostId = widget.data['hostId'] ?? '';
    final coverImage = widget.data['coverImage'] ?? '';
    final price = widget.data['price']?.toString() ?? '0';
    final maxGuests = widget.data['maxGuests']?.toString() ?? 'N/A';
    final duration = widget.data['duration']?.toString() ?? 'N/A';
    final location = widget.data['location'] as Map<String, dynamic>?;
    final city = location?['city'] ?? 'Unknown City';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        children: [
          // Header handle
          Container(
            height: 5,
            width: 40,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover Image
                  if (coverImage.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: CachedNetworkImage(
                        imageUrl: coverImage,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),

                  // Title & Meta
                  Text(
                    title,
                    style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _buildPill(Icons.attach_money, '\$$price'),
                      const SizedBox(width: AppSpacing.sm),
                      _buildPill(Icons.people, 'Max $maxGuests'),
                      const SizedBox(width: AppSpacing.sm),
                      _buildPill(Icons.timer, '${duration}m'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(city, style: AppTypography.titleMedium),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Description
                  Text('Description',
                      style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(desc, style: AppTypography.bodyMedium),
                  const SizedBox(height: AppSpacing.xl),

                  // Host Information Block
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hosted By',
                              style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hostName,
                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        OutlinedButton(
                          onPressed: () {
                            if (hostId.isNotEmpty) {
                              context.push('/user/$hostId');
                            }
                          },
                          child: const Text('View Profile'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Danger Zone (Deletion Script)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 40),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Danger Zone',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'Deleting this experience will permanently erase it from the platform. It will automatically notify the Host and cancel any existing Bookings connected to it.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.error),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _isDeleting ? null : () => _executeDeletion(hostId),
                            child: _isDeleting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Permanently Delete Listing', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.labelMedium),
        ],
      ),
    );
  }

  Future<void> _executeDeletion(String hostId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Experience?'),
        content: const Text(
            'This action is irreversible. It will notify the host and all seekers who have booked it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Admin not authenticated');

      final idToken = await user.getIdToken();
      // Connect to the proxy Node backend
      final String backendUrl = AppConfig.baseUrl; 

      final response = await http.post(
        Uri.parse('$backendUrl/api/admin/delete-experience'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode({
          'experienceId': widget.experienceId,
          'hostId': hostId,
          'title': widget.data['title'],
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context); // Close the sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Experience successfully deleted and notifications dispatched.'), backgroundColor: AppColors.success),
          );
        }
      } else {
        throw Exception('Server error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete experience: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }
}
