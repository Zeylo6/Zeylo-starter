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
        automaticallyImplyLeading: false,
        leadingWidth: 100,
        leading: Row(
          children: [
            if (!isCurrentUser)
              IconButton(
                icon: const Icon(Icons.arrow_back),
                color: AppColors.textPrimary,
                onPressed: () => Navigator.pop(context),
              ),
            profileAsync.when(
              data: (profile) => Padding(
                padding: EdgeInsets.only(left: isCurrentUser ? AppSpacing.md : 0),
                child: profile.averageRating != null
                    ? _buildRatingIndicator(profile.averageRating!)
                    : const SizedBox.shrink(),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
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

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(profileProvider(userId));
        ref.invalidate(currentUserProvider);
        // Wait a small bit to allow fresh data to stream in
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            ProfileHeader(
              profile: profile,
              onEditPressed: isCurrentUser ? (onEditPressed ?? () => context.push('/edit-profile')) : null,
            ),

            // Premium Profile Actions (Replacing the old dashboard card)
            if (isCurrentUser && currentUserData != null)
              _buildPremiumActions(context, currentUserData),

            const SizedBox(height: AppSpacing.xl),

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
      ),
    );
  }

  void _showMoreMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCurrentUser) ...[
              // Developer/Admin - Clear Bookings
              ListTile(
                leading: const Icon(Icons.delete_sweep, color: AppColors.error),
                title: const Text('Clear All Bookings (Dev)',
                    style: TextStyle(
                        color: AppColors.error, fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  try {
                    final snapshot = await FirebaseFirestore.instance
                        .collection('bookings')
                        .get();
                    for (var doc in snapshot.docs) {
                      await doc.reference.delete();
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('All bookings cleared successfully.')));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Failed to clear bookings: $e')));
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

  Widget _buildPremiumActions(BuildContext context, UserEntity user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Dashboard',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (user.role == UserRole.seeker)
            _buildActionCard(
              context: context,
              title: 'My Bookings',
              subtitle: 'Manage your upcoming experiences',
              icon: Icons.calendar_today_rounded,
              color: const Color(0xFF6C63FF),
              onTap: () => context.push('/seeker-dashboard'),
            ),
          if (user.role == UserRole.host)
            _buildActionCard(
              context: context,
              title: 'Host Control Center',
              subtitle: 'Listing management & analytics',
              icon: Icons.dashboard_customize_rounded,
              color: const Color(0xFFFF9A3C),
              onTap: () => context.push('/host-dashboard', extra: {
                'hostId': user.uid,
                'hostName': user.displayName,
                'hostPhotoUrl': user.photoUrl,
                'isSuperhost': false,
              }),
            ),
          if (user.role == UserRole.business)
            _buildActionCard(
              context: context,
              title: 'Business Suite',
              subtitle: 'Verify & manage your storefront',
              icon: Icons.storefront_rounded,
              color: const Color(0xFF11998E),
              onTap: () => context.push('/business-registration'),
            ),
          if (user.role == UserRole.admin)
            _buildActionCard(
              context: context,
              title: 'Admin Oversight',
              subtitle: 'System health & moderation',
              icon: Icons.admin_panel_settings_rounded,
              color: const Color(0xFF8E2DE2),
              onTap: () => context.push('/admin-dashboard'),
            ),
          _buildActionCard(
            context: context,
            title: 'Privacy & Security',
            subtitle: 'Manage your data and account',
            icon: Icons.security_rounded,
            color: Colors.blueGrey,
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmallSecondary,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textHint.withOpacity(0.5),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingIndicator(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 16),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

}
