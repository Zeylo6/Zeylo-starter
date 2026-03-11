import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/config/app_config.dart';
import 'package:intl/intl.dart';

class AdminReportsTab extends StatefulWidget {
  const AdminReportsTab({super.key});

  @override
  State<AdminReportsTab> createState() => _AdminReportsTabState();
}

class _AdminReportsTabState extends State<AdminReportsTab> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Padding(
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
            
            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  color: AppColors.primary,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: const [
                  Tab(text: 'Pending Review'),
                  Tab(text: 'Monitoring'),
                ],
              ),
            ),
            
            SizedBox(height: AppSpacing.lg),
            Expanded(
              child: TabBarView(
                children: [
                  _buildReportList('pending'),
                  _buildReportList('action_taken'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportList(String status) {
    final isMonitoring = status == 'action_taken';
    final primaryColor = isMonitoring ? Colors.indigo : AppColors.error;
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reports')
          .where('status', isEqualTo: status)
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
                        Icon(
                          isMonitoring ? Icons.verified_user_outlined : Icons.check_circle_outline,
                          size: 60, 
                          color: isMonitoring ? Colors.indigo : AppColors.success
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          isMonitoring ? 'No users in monitoring' : 'All clear!', 
                          style: AppTypography.titleLarge
                        ),
                        Text(
                          isMonitoring ? 'Records will appear here after a warning is issued.' : 'No pending reports to review.',
                          style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.textSecondary)
                        ),
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
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: primaryColor.withOpacity(0.2)),
                                  ),
                                  child: Text(
                                    data['reporterRole']
                                            ?.toString()
                                            .toUpperCase() ??
                                        'UNKNOWN',
                                    style: TextStyle(
                                        color: primaryColor,
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
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: primaryColor.withOpacity(0.2)),
                                  ),
                                  child: Text(
                                    data['reportedRole']
                                            ?.toString()
                                            .toUpperCase() ??
                                        'UNKNOWN',
                                    style: TextStyle(
                                        color: primaryColor,
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

                            // History Tag for Monitoring
                            if (isMonitoring) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.history, size: 14, color: Colors.indigo),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Last Action: ${data['actionType'] == 'warning_email' ? 'Warning Sent' : 'Restricted'}',
                                      style: const TextStyle(
                                        color: Colors.indigo,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (data['updatedAt'] != null)
                                      Text(
                                        DateFormat.yMMMd().format((data['updatedAt'] as Timestamp).toDate()),
                                        style: TextStyle(color: Colors.indigo.withOpacity(0.6), fontSize: 10),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: AppSpacing.md),
                            ],

                            const Divider(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (!isMonitoring)
                                  TextButton(
                                    onPressed: () =>
                                        _dismissReport(context, doc.id),
                                    child: Text('Dismiss',
                                        style: TextStyle(
                                            color: AppColors.textSecondary)),
                                  ),
                                if (isMonitoring)
                                  TextButton.icon(
                                    onPressed: () => _deleteReport(context, doc.id),
                                    icon: const Icon(Icons.delete_outline, size: 18),
                                    label: const Text('Delete'),
                                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                  ),
                                SizedBox(width: AppSpacing.sm),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _showActionSheet(context, doc.id, data, isMonitoring),
                                  icon: Icon(
                                    isMonitoring ? Icons.verified_rounded : Icons.gavel_rounded,
                                    size: 18, 
                                    color: Colors.white
                                  ),
                                  label: Text(
                                    isMonitoring ? 'Management' : 'Take Action',
                                    style: const TextStyle(color: Colors.white)
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
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

  Future<void> _deleteReport(BuildContext context, String reportId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Report?'),
        content: const Text('This will permanently remove the record from monitoring.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Delete', style: TextStyle(color: AppColors.error))
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance.collection('reports').doc(reportId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report deleted.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  Future<void> _resolveReport(BuildContext context, String reportId) async {
    try {
      await FirebaseFirestore.instance.collection('reports').doc(reportId).update({
        'status': 'resolved',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Report marked as Resolved.'),
          backgroundColor: AppColors.success,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  void _showActionSheet(BuildContext context, String reportId, Map<String, dynamic> reportData, bool isMonitoring) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
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
            const SizedBox(height: AppSpacing.xl),
            Text(isMonitoring ? 'Manage Monitoring' : 'Take Disciplinary Action',
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isMonitoring 
                ? 'Review user progress after warning or finalize the status.'
                : 'Choose the appropriate response for this report. Action will be logged permanently.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            if (!isMonitoring) ...[
              _buildActionTile(
                icon: Icons.alternate_email_rounded,
                title: 'Send Warning Email',
                subtitle: 'Notifies user of violation and moves to Monitoring.',
                color: AppColors.error,
                onTap: () {
                  Navigator.pop(ctx);
                  _executeAction(context, reportId, reportData, 'warning_email');
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            if (isMonitoring) ...[
              _buildActionTile(
                icon: Icons.check_circle_outline,
                title: 'Mark as Resolved',
                subtitle: 'The issue is no longer a concern. Cleared from dashboard.',
                color: AppColors.success,
                onTap: () {
                  Navigator.pop(ctx);
                  _resolveReport(context, reportId);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildActionTile(
                icon: Icons.alternate_email_rounded,
                title: 'Send Warning Email Again',
                subtitle: 'Re-issues a formal warning to the reported user.',
                color: AppColors.error,
                onTap: () {
                  Navigator.pop(ctx);
                  _executeAction(context, reportId, reportData, 'warning_email');
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            _buildActionTile(
              icon: Icons.block_flipped,
              title: 'Ban User Account',
              subtitle: 'Permanent platform restriction. High impact action.',
              color: Colors.black,
              onTap: () {
                Navigator.pop(ctx);
                _executeAction(context, reportId, reportData, 'ban_user');
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  // TODO: Update this to your deployed backend URL in production
  static String get _backendUrl => AppConfig.baseUrl;
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

      // 4. Call backend for specific action
      try {
        final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
        if (idToken != null) {
          final endpoint = actionType == 'ban_user' 
              ? '/api/admin/ban-user'
              : '/api/admin/send-warning-email';
          
          final body = actionType == 'ban_user'
              ? {
                  'targetUserId': reportedUserId,
                  'reason': reportData['reason'] ?? 'Policy violation',
                }
              : {
                  'reportedUserId': reportedUserId,
                  'reason': reportData['reason'] ?? 'Policy violation',
                  'details': reportData['details'] ?? '',
                };

          final response = await http
              .post(
                Uri.parse('$_backendUrl$endpoint'),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $idToken',
                },
                body: jsonEncode(body),
              )
              .timeout(const Duration(seconds: 15));

          if (response.statusCode == 200) {
            debugPrint('$actionType executed successfully on backend');
          } else {
            debugPrint(
                'Backend API responded with error: ${response.statusCode} - ${response.body}');
          }
        }
      } catch (backendError) {
        debugPrint('Backend call failed: $backendError');
      }

      if (context.mounted) {
        final message = actionType == 'ban_user'
            ? 'User Account Banned successfully.'
            : actionType == 'warning_email'
                ? 'Warning Email Sent.'
                : 'User Restricted successfully.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
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
