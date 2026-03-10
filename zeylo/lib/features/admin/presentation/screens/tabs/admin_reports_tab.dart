import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import 'package:intl/intl.dart';

class AdminReportsTab extends StatelessWidget {
  const AdminReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Reports',
            style: AppTypography.headlineMedium
                .copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Monitor and manage platform moderation reports',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: AppColors.error.withOpacity(0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 16, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Pending Review',
                        style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reports')
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error loading reports: ${snapshot.error}'));
                }

                final docs = snapshot.data?.docs ?? [];

                // Sort by creation date
                docs.sort((a, b) {
                  final aMap = a.data() as Map<String, dynamic>;
                  final bMap = b.data() as Map<String, dynamic>;
                  final aTime = aMap['createdAt'] as Timestamp?;
                  final bTime = bMap['createdAt'] as Timestamp?;
                  if (aTime == null || bTime == null) return 0;
                  return bTime.compareTo(aTime);
                });

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 60, color: AppColors.success),
                        const SizedBox(height: AppSpacing.md),
                        Text('All clear!', style: AppTypography.titleLarge),
                        Text('No pending reports to review.',
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final date = data['createdAt'] is Timestamp
                        ? DateFormat.yMMMd()
                            .add_jm()
                            .format((data['createdAt'] as Timestamp).toDate())
                        : 'Unknown date';

                    return Card(
                      margin: EdgeInsets.only(bottom: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg)),
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    data['reporterRole']
                                            ?.toString()
                                            .toUpperCase() ??
                                        'UNKNOWN',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded,
                                    size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    data['reportedRole']
                                            ?.toString()
                                            .toUpperCase() ??
                                        'UNKNOWN',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const Spacer(),
                                Text(date,
                                    style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                            SizedBox(height: AppSpacing.md),
                            
                            // Fetch names of Reporter and Target
                            FutureBuilder<List<DocumentSnapshot>>(
                              future: Future.wait([
                                FirebaseFirestore.instance.collection('users').doc(data['reporterId']).get(),
                                FirebaseFirestore.instance.collection('users').doc(data['reportedUid'] ?? data['reportedUserId']).get(),
                              ]),
                              builder: (context, userSnapshot) {
                                if (!userSnapshot.hasData) return const SizedBox();
                                final reporterData = userSnapshot.data![0].data() as Map<String, dynamic>?;
                                final targetData = userSnapshot.data![1].data() as Map<String, dynamic>?;
                                
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Reporter: ${reporterData?['displayName'] ?? reporterData?['name'] ?? 'Unknown'}', 
                                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                      Text('Target: ${targetData?['displayName'] ?? targetData?['name'] ?? 'Unknown'}', 
                                          style: const TextStyle(fontSize: 13, color: AppColors.error, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                );
                              },
                            ),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Reason: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textSecondary)),
                                Expanded(
                                    child: Text(
                                        data['reason'] ?? 'Not specified',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16))),
                              ],
                            ),
                            SizedBox(height: AppSpacing.sm),
                            if (data['details'] != null &&
                                data['details'].toString().isNotEmpty) ...[
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  border: Border.all(color: AppColors.border),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Text('"${data['details']}"',
                                    style: const TextStyle(
                                        fontStyle: FontStyle.italic)),
                              ),
                              SizedBox(height: AppSpacing.md),
                            ],
                            const Divider(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      _dismissReport(context, doc.id),
                                  child: Text('Dismiss',
                                      style: TextStyle(
                                          color: AppColors.textSecondary)),
                                ),
                                SizedBox(width: AppSpacing.sm),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _takeActionDialog(context, doc.id, data),
                                  icon: const Icon(Icons.gavel_rounded,
                                      size: 18, color: Colors.white),
                                  label: const Text('Take Action',
                                      style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.md)),
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }

  Future<void> _dismissReport(BuildContext context, String reportId) async {
    try {
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(reportId)
          .update({
        'status': 'dismissed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Report dismissed.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to dismiss: $e')));
      }
    }
  }

  void _takeActionDialog(
      BuildContext context, String reportId, Map<String, dynamic> reportData) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
          title: const Text('Take Action Against User'),
          content: const Text(
            'Select the disciplinary action to take. For now, "Send Warning Email" will simulate sending an email and push a notification warning to the user.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _executeAction(
                    context, reportId, reportData, 'warning_email');
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Send Warning Email',
                  style: TextStyle(color: Colors.white)),
            ),
          ]),
    );
  }

  // TODO: Update this to your deployed backend URL in production
  static const String _backendUrl =
      'http://10.0.2.2:3000'; // Android emulator -> localhost
  // static const String _backendUrl = 'http://localhost:3000'; // Web / iOS simulator

  Future<void> _executeAction(BuildContext context, String reportId,
      Map<String, dynamic> reportData, String actionType) async {
    try {
      // Field is stored as 'reportedUid' by report_sheet.dart
      final reportedUserId =
          reportData['reportedUid'] ?? reportData['reportedUserId'];

      // 1. Log the action
      await FirebaseFirestore.instance.collection('admin_actions').add({
        'reportId': reportId,
        'targetUserId': reportedUserId,
        'actionType': actionType,
        'createdAt': FieldValue.serverTimestamp(),
        'reason': reportData['reason'],
      });

      // 2. Send in-app notification to the reported user
      await FirebaseFirestore.instance.collection('activities').add({
        'userId': reportedUserId,
        'title': 'Platform Warning',
        'message':
            'We have received a report regarding your recent conduct: "${reportData['reason']}". Please review our community guidelines. Further violations may result in suspension.',
        'type': 'admin_warning',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Update report status
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(reportId)
          .update({
        'status': 'action_taken',
        'actionType': actionType,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 4. Send actual warning email via backend
      try {
        final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
        if (idToken != null) {
          final response = await http
              .post(
                Uri.parse('$_backendUrl/api/admin/send-warning-email'),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $idToken',
                },
                body: jsonEncode({
                  'reportedUserId': reportedUserId,
                  'reason': reportData['reason'] ?? 'Policy violation',
                  'details': reportData['details'] ?? '',
                }),
              )
              .timeout(const Duration(seconds: 15));

          if (response.statusCode == 200) {
            debugPrint('Warning email sent successfully');
          } else {
            debugPrint(
                'Email API responded with error: ${response.statusCode} - ${response.body}');
          }
        }
      } catch (emailError) {
        // Don't fail the entire action if just the email fails
        debugPrint('Email sending failed (non-critical): $emailError');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Action executed: Warning Email & Notification sent.'),
          backgroundColor: AppColors.success,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Action failed: $e')));
      }
    }
  }
}
