import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeylo/core/theme/app_colors.dart';
import 'package:zeylo/core/theme/app_radius.dart';
import 'package:zeylo/core/theme/app_spacing.dart';
import 'package:zeylo/core/theme/app_typography.dart';
import 'package:zeylo/features/auth/presentation/providers/auth_provider.dart';
import 'package:zeylo/features/community/presentation/providers/community_provider.dart';
import 'package:zeylo/features/profile/domain/entities/user_profile_entity.dart';
import 'package:zeylo/features/profile/presentation/providers/profile_provider.dart';
import 'package:zeylo/features/profile/presentation/widgets/photo_grid.dart';
import 'package:zeylo/features/profile/presentation/widgets/profile_header.dart';
import '../widgets/past_experience_tile.dart';
import '../../../booking/presentation/providers/booking_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../favorites/presentation/widgets/favorites_bottom_sheet.dart';

/// Glassmorphism user profile screen
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3EEFF),
              Color(0xFFF9F7FF),
              Color(0xFFEDE9FE),
              Color(0xFFF5F3FF),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Decorative orbs
            Positioned(
              top: -50,
              right: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.12),
                      AppColors.primary.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 150,
              left: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gradientEnd.withOpacity(0.08),
                      AppColors.gradientEnd.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            CustomScrollView(
              slivers: [
                // Glass app bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  floating: true,
                  snap: true,
                  pinned: false,
                  toolbarHeight: 64,
                  automaticallyImplyLeading: false,
                  flexibleSpace: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.5),
                              Colors.white.withOpacity(0.3),
                            ],
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withOpacity(0.5),
                              width: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  leading: !isCurrentUser
                      ? _GlassIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context),
                        )
                      : profileAsync.when(
                          data: (profile) => profile.averageRating != null
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: AppSpacing.sm),
                                  child: Center(
                                    child: _buildRatingIndicator(
                                        profile.averageRating!),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: _GlassIconButton(
                        icon: Icons.more_vert_rounded,
                        onTap: () => _showMoreMenu(context, ref),
                      ),
                    ),
                  ],
                ),
                // Body
                profileAsync.when(
                  data: (profile) => SliverToBoxAdapter(
                    child: _buildContent(context, ref, profile),
                  ),
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => SliverFillRemaining(
                    child: Center(child: Text('Error: $error')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    UserProfileEntity profile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile header
        ProfileHeader(
          profile: profile,
          onEditPressed: isCurrentUser ? onEditPressed : null,
        ),
        const SizedBox(height: AppSpacing.md),

        // Posts section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.grid_on_rounded,
                  color: AppColors.textPrimary, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text('Posts', style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
              )),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Photo grid
        ref.watch(userPostsProvider(userId)).when(
              data: (posts) {
                final photoUrls =
                    posts.expand((post) => post.images).toList();
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  child: PhotoGrid(
                    photoUrls: photoUrls,
                    onPhotoPressed: () {
                      context.push('/user-posts', extra: {
                        'userId': userId,
                        'userName': profile.name,
                        'userAvatarUrl': profile.photoUrl,
                      });
                    },
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child:
                    Center(child: Text('Error loading posts: $error')),
              ),
            ),

        const SizedBox(height: AppSpacing.xl),

        // Past experiences section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Past Experiences',
                  style: AppTypography.labelLarge
                      .copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(width: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.2),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline_rounded,
                            size: 11, color: AppColors.success),
                        const SizedBox(width: 3),
                        Text(
                          'Private',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.success,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Past experiences list
        if (isCurrentUser)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: ref.watch(pastBookingsProvider(userId)).when(
                  data: (pastBookings) {
                    if (pastBookings.isEmpty) {
                      return _buildEmptyState(
                        icon: Icons.history_rounded,
                        message: 'No past experiences yet',
                      );
                    }
                    return Column(
                      children: pastBookings.map<Widget>((booking) {
                        return PastExperienceTile(
                          experienceId: booking.experienceId,
                          title: booking.experienceTitle,
                          price: booking.totalPrice,
                          date: booking.date,
                          status: booking.status,
                          imageUrl: booking.experienceCoverImage,
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => _buildEmptyState(
                    icon: Icons.error_outline_rounded,
                    message: 'Could not load past experiences',
                  ),
                ),
          ),

        const SizedBox(height: AppSpacing.xl),

        // Logout button
        if (isCurrentUser && onLogoutPressed != null)
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.error.withOpacity(0.08),
                        AppColors.error.withOpacity(0.04),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.25),
                      width: 1.2,
                    ),
                  ),
                  child: TextButton(
                    onPressed: onLogoutPressed,
                    child: Text(
                      'Log out',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Premium actions
        if (isCurrentUser)
          ref.watch(currentUserProvider).when(
                data: (user) => user != null
                    ? _buildPremiumActions(context, user)
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.5),
                  Colors.white.withOpacity(0.25),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                Icon(icon,
                    size: 40,
                    color: AppColors.textSecondary.withOpacity(0.4)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ClipRRect(
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.75),
                  Colors.white.withOpacity(0.55),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24)),
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 1,
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.textHint.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  if (isCurrentUser) ...[
                    ListTile(
                      leading: const Icon(Icons.settings_rounded),
                      title: const Text('Settings'),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        context.push('/settings');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.logout_rounded,
                          color: AppColors.error),
                      title: Text('Sign Out',
                          style: TextStyle(color: AppColors.error)),
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        try {
                          await ref
                              .read(authNotifierProvider.notifier)
                              .signOut();
                          if (context.mounted) context.go('/login');
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
                      leading: const Icon(Icons.report_problem_rounded),
                      title: const Text('Report'),
                      onTap: () => Navigator.pop(sheetContext),
                    ),
                    ListTile(
                      leading: const Icon(Icons.block_rounded),
                      title: const Text('Block'),
                      onTap: () => Navigator.pop(sheetContext),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
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
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Account Dashboard',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (user.role == UserRole.seeker)
            _buildGlassActionCard(
              context: context,
              title: 'My Bookings',
              subtitle: 'Manage your upcoming experiences',
              icon: Icons.calendar_today_rounded,
              color: const Color(0xFF6C63FF),
              onTap: () => context.push('/seeker-dashboard'),
            ),
          if (user.role == UserRole.seeker)
            _buildGlassActionCard(
              context: context,
              title: 'My Favorites',
              subtitle: 'Quick access to saved experiences',
              icon: Icons.favorite_rounded,
              color: const Color(0xFFFF4B2B),
              onTap: () => _showFavoritesBottomSheet(context),
            ),
          if (user.role == UserRole.host)
            _buildGlassActionCard(
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
            _buildGlassActionCard(
              context: context,
              title: 'Business Suite',
              subtitle: 'Verify & manage your storefront',
              icon: Icons.storefront_rounded,
              color: const Color(0xFF11998E),
              onTap: () => context.push('/business-registration'),
            ),
          if (user.role == UserRole.admin)
            _buildGlassActionCard(
              context: context,
              title: 'Admin Oversight',
              subtitle: 'System health & moderation',
              icon: Icons.admin_panel_settings_rounded,
              color: const Color(0xFF8E2DE2),
              onTap: () => context.push('/admin-dashboard'),
            ),
        ],
      ),
    );
  }

  Widget _buildGlassActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.55),
                    Colors.white.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: Colors.white.withOpacity(0.65),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.15),
                          color.withOpacity(0.06),
                        ],
                      ),
                      border: Border.all(
                        color: color.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(subtitle,
                            style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.5),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 1,
                      ),
                    ),
                    child: const Icon(Icons.chevron_right_rounded,
                        size: 18, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingIndicator(double rating) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.6),
                Colors.white.withOpacity(0.35),
              ],
            ),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: Colors.amber.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded,
                  color: Color(0xFFFFB800), size: 16),
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
        ),
      ),
    );
  }

  void _showFavoritesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FavoritesBottomSheet(),
    );
  }
}

/// Reusable glass icon button for app bar
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.6),
                    Colors.white.withOpacity(0.3),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.7),
                  width: 1.2,
                ),
              ),
              child: Icon(icon, size: 20, color: AppColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
