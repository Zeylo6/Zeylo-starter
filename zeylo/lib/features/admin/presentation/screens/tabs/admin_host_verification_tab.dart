import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/custom_text_field.dart';

class AdminHostVerificationTab extends StatefulWidget {
  const AdminHostVerificationTab({super.key});

  @override
  State<AdminHostVerificationTab> createState() => _AdminHostVerificationTabState();
}

class _AdminHostVerificationTabState extends State<AdminHostVerificationTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Host Verification Required',
            style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Review and approve or reject identity verifications for new hosts.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ZeyloTextField(
              label: '',
              hint: 'Search by host name...',
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('host_verifications')
                    .orderBy('submittedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading requests: ${snapshot.error}'));
                  }

                  var docs = snapshot.data?.docs ?? [];

                  if (_searchQuery.isNotEmpty) {
                    docs = docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data['fullName'] ?? '').toString().toLowerCase();
                      return name.contains(_searchQuery);
                    }).toList();
                  }

                  if (docs.isEmpty) {
                    return const Center(child: Text('No verification requests found.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final status = data['status'] ?? 'pending';
                      final submittedAt = (data['submittedAt'] as Timestamp?)?.toDate();
                      final dateStr = submittedAt != null 
                          ? DateFormat('MMM dd, yyyy - hh:mm a').format(submittedAt) 
                          : 'Unknown Date';

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          side: BorderSide(color: AppColors.border.withOpacity(0.6)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: _getStatusColor(status).withOpacity(0.15),
                                child: Icon(_getStatusIcon(status), color: _getStatusColor(status), size: 28),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['fullName'] ?? 'Unknown Name',
                                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Submitted: $dateStr',
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    _buildStatusChip(status),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xl),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                                label: const Text('Review', style: TextStyle(fontWeight: FontWeight.w600)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                                ),
                                onPressed: () => _showVerificationDetailsDialog(context, data, doc.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: _getStatusColor(status).withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'verified': return AppColors.success;
      case 'rejected': return AppColors.error;
      case 'pending': return AppColors.warning;
      default: return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'verified': return Icons.verified;
      case 'rejected': return Icons.block;
      case 'pending': return Icons.hourglass_empty;
      default: return Icons.help_outline;
    }
  }

  Future<void> _updateVerificationStatus(String verificationId, String hostId, String status, {String? rejectionReason}) async {
    final batch = FirebaseFirestore.instance.batch();

    // 1. Update verification document
    final verificationRef = FirebaseFirestore.instance.collection('host_verifications').doc(verificationId);
    batch.update(verificationRef, {
      'status': status,
      'reviewedAt': FieldValue.serverTimestamp(),
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    });

    // 2. Update user profile document
    final userRef = FirebaseFirestore.instance.collection('users').doc(hostId);
    batch.update(userRef, {
      'hostVerificationStatus': status,
    });

    // 2.5 Sync existing experiences
    final experiencesQuery = await FirebaseFirestore.instance
        .collection('experiences')
        .where('hostId', isEqualTo: hostId)
        .get();
        
    for (var doc in experiencesQuery.docs) {
      batch.update(doc.reference, {
        'isHostVerified': status == 'verified'
      });
    }

    // 3. Send Notification to Host
    final notificationRef = FirebaseFirestore.instance.collection('activities').doc();
    batch.set(notificationRef, {
      'userId': hostId,
      'title': status == 'verified' ? 'Verification Approved' : 'Verification Rejected',
      'message': status == 'verified' 
          ? 'Congratulations! Your host verification request has been approved. You can now host experiences.'
          : 'Your host verification request was rejected. Reason: ${rejectionReason ?? "Please check community guidelines."}',
      'type': 'host_verification',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    try {
      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Host marked as $status successfully.'))
        );
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to update status: $e'), backgroundColor: AppColors.error)
         );
      }
    }
  }

  void _showRejectDialog(BuildContext context, String verificationId, String hostId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for rejecting this verification request. This will be shown to the host.'),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason for rejection...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide a reason')));
                 return;
              }
              Navigator.pop(ctx);
              _updateVerificationStatus(verificationId, hostId, 'rejected', rejectionReason: reasonController.text.trim());
            },
            child: const Text('Reject Request', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showVerificationDetailsDialog(BuildContext context, Map<String, dynamic> data, String verificationId) {
    final dob = (data['dateOfBirth'] as Timestamp?)?.toDate();
    final dobStr = dob != null ? DateFormat('MMM dd, yyyy').format(dob) : 'N/A';
    final status = data['status'] ?? 'pending';
    
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Verification Details', style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: AppSpacing.xxl),
              
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow('Host Name:', data['fullName'] ?? 'N/A'),
                            const SizedBox(height: AppSpacing.sm),
                            _buildDetailRow('Date of Birth:', dobStr),
                            const SizedBox(height: AppSpacing.sm),
                            _buildDetailRow('Current Status:', status.toUpperCase(), color: _getStatusColor(status)),
                            if (data['rejectionReason'] != null && status == 'rejected') ...[
                              const SizedBox(height: AppSpacing.sm),
                              _buildDetailRow('Rejection Reason:', data['rejectionReason'], color: AppColors.error),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.xxl),
                      Text('Proof Documents', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.md),
                      
                      if (data['nicImageUrl'] != null) ...[
                        _buildDocumentSection('National Identity Card (Mandatory)', data['nicImageUrl']),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                      
                      if (data['passportImageUrl'] != null) ...[
                        _buildDocumentSection('Passport (Optional)', data['passportImageUrl']),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                      
                      if (data['driversLicenseImageUrl'] != null) ...[
                        _buildDocumentSection('Driver\'s License (Optional)', data['driversLicenseImageUrl']),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ],
                  ),
                ),
              ),
              
              if (status == 'pending') ...[
                const Divider(height: AppSpacing.xxl),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel & Close', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.close, size: 20),
                      label: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error.withOpacity(0.1),
                        foregroundColor: AppColors.error,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showRejectDialog(context, verificationId, verificationId);
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text('Approve', style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _updateVerificationStatus(verificationId, verificationId, 'verified');
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDocumentSection(String title, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.description_outlined, color: AppColors.secondary, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(title, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildImagePreview(url),
      ],
    );
  }
  
  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImagePreview(String url) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Image.network(
           url,
           fit: BoxFit.contain,
           errorBuilder: (_, __, ___) => const Center(child: Text('Failed to load image')),
           loadingBuilder: (context, child, progress) {
             if (progress == null) return child;
             return const Center(child: CircularProgressIndicator());
           },
        ),
      ),
    );
  }
}
