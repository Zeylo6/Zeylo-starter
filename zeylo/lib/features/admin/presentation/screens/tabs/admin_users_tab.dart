import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/custom_text_field.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Management',
            style: AppTypography.headlineMedium
                .copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Manage all seekers, hosts, and businesses',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: 400,
            child: ZeyloTextField(
              label: '',
              hint: 'Search by name or email...',
              controller: _searchController,
              onChanged: (val) =>
                  setState(() => _searchQuery = val.toLowerCase()),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error loading users: ${snapshot.error}'));
                  }

                  var docs = snapshot.data?.docs ?? [];

                  if (_searchQuery.isNotEmpty) {
                    docs = docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name =
                          (data['displayName'] ?? '').toString().toLowerCase();
                      final email =
                          (data['email'] ?? '').toString().toLowerCase();
                      return name.contains(_searchQuery) ||
                          email.contains(_searchQuery);
                    }).toList();
                  }

                  if (docs.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final role = data['role'] ?? 'seeker';
                      final isBanned = data['isBanned'] == true;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: data['photoUrl'] != null
                              ? NetworkImage(data['photoUrl'])
                              : null,
                          child: data['photoUrl'] == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Row(
                          children: [
                            Text(data['displayName'] ?? 'Unknown User',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            if (isBanned) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('BANNED',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ]
                          ],
                        ),
                        subtitle: Text(
                            '${data['email']} • Role: ${role.toString().toUpperCase()}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'ban') {
                              await doc.reference
                                  .update({'isBanned': !isBanned});
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(isBanned
                                            ? 'User unbanned'
                                            : 'User banned')));
                              }
                            } else if (value == 'view') {
                              // Future feature: View detailed profile
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'view', child: Text('View Details')),
                            PopupMenuItem(
                              value: 'ban',
                              child: Text(isBanned ? 'Unban User' : 'Ban User',
                                  style: TextStyle(
                                      color: isBanned
                                          ? AppColors.success
                                          : AppColors.error)),
                            ),
                          ],
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
}
