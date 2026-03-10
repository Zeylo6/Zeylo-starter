import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../providers/profile_provider.dart';
import '../widgets/past_experience_tile.dart';
import '../widgets/photo_grid.dart';
import '../widgets/profile_header.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// User profile screen
class ProfileScreen extends ConsumerWidget {
  final String userId;
  final bool isCurrentUser;
  final VoidCallback? onEditPressed;
  final VoidCallback? onLogoutPressed;

  const ProfileScreen({
    required this.userId,
    this.isCurrentUser = false,
    this.onEditPressed,
    this.onLogoutPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(userId));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: !isCurrentUser,
        leading: isCurrentUser
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                color: AppColors.textPrimary,
                onPressed: () => Navigator.pop(context),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            color: AppColors.textPrimary,
            onPressed: () => _showMoreMenu(context, ref),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) => _buildContent(context, ref, profile),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    UserProfileEntity profile,
  ) {
    // Read the current user model persistently loaded from Firestore
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUserData = currentUserAsync.value;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          ProfileHeader(
            profile: profile,
            onEditPressed: isCurrentUser ? onEditPressed : null,
          ),
          
          // Premium Role Badge
          if (isCurrentUser && currentUserData != null)
            _buildRoleBadge(currentUserData.role.name),

          const Divider(height: 1),

          // Posts section
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                const Icon(Icons.grid_on, color: AppColors.textPrimary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Posts',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Photo grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: PhotoGrid(
              photoUrls: const [], // Load from backend
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),

          // Past experiences section
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Past Experiences',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            size: 12,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Private',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Past experiences list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                PastExperienceTile(
                  experienceId: '1',
                  title: 'Traditional Cooking Adventure',
                  rating: 4.9,
                  ratingCount: 234,
                  price: 45,
                ),
                PastExperienceTile(
                  experienceId: '2',
                  title: 'Sunrise watching',
                  rating: 4.8,
                  ratingCount: 156,
                  price: 35,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Logout button (if current user)
          if (isCurrentUser && onLogoutPressed != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: onLogoutPressed,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.error,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Text(
                    'Log out',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  void _showMoreMenu(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.read(currentUserProvider);
    final currentUserData = currentUserAsync.value;

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCurrentUser) ...[
              // Admin Route
              if (currentUserData?.role == UserRole.admin)
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings, color: AppColors.primary),
                  title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push('/admin-dashboard');
                  },
                ),
              // Business Route
              if (currentUserData?.role == UserRole.business)
                ListTile(
                  leading: const Icon(Icons.storefront, color: AppColors.primary),
                  title: const Text('Business Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    // For now, mapping this to the registration/management screen
                    context.push('/business-registration');
                  },
                ),
              // Host Route
              if (currentUserData?.role == UserRole.host)
                ListTile(
                  leading: const Icon(Icons.home_work_outlined, color: AppColors.primary),
                  title: const Text('Host Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push('/host-dashboard', extra: {
                      'hostId': currentUserData?.uid,
                      'hostName': currentUserData?.displayName ?? 'Host',
                      'hostPhotoUrl': currentUserData?.photoUrl,
                      'isSuperhost': false,
                    });
                  },
                ),
              // Developer/Admin - Clear Bookings
              ListTile(
                leading: const Icon(Icons.delete_sweep, color: AppColors.error),
                title: const Text('Clear All Bookings (Dev)', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  try {
                    final snapshot = await FirebaseFirestore.instance.collection('bookings').get();
                    for (var doc in snapshot.docs) {
                      await doc.reference.delete();
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All bookings cleared successfully.')));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to clear bookings: $e')));
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push('/settings');
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: Text(
                  'Sign Out',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  try {
                    await ref.read(authNotifierProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.report_problem),
                title: const Text('Report'),
                onTap: () => Navigator.pop(sheetContext),
              ),
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Block'),
                onTap: () => Navigator.pop(sheetContext),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String roleName) {
    final roleData = {
      'seeker':  {'emoji': '🔍', 'label': 'Seeker',   'start': const Color(0xFF6C63FF), 'end': const Color(0xFF48CAE4)},
      'host':    {'emoji': '🏡', 'label': 'Host',     'start': const Color(0xFFFF9A3C), 'end': const Color(0xFFFF6B6B)},
      'business':{'emoji': '💼', 'label': 'Business', 'start': const Color(0xFF11998E), 'end': const Color(0xFF38EF7D)},
      'admin':   {'emoji': '🛡️', 'label': 'Admin',   'start': const Color(0xFF8E2DE2), 'end': const Color(0xFF4A00E0)},
    };
    final data = roleData[roleName] ?? roleData['seeker']!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [data['start'] as Color, data['end'] as Color],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: [
            BoxShadow(
              color: (data['start'] as Color).withAlpha(77),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(data['emoji'] as String, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              data['label'] as String,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

