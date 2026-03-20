import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

// Import the tabs we will build below
import 'tabs/admin_overview_tab.dart';
import 'tabs/admin_users_tab.dart';
import 'tabs/admin_reports_tab.dart';
import 'tabs/admin_businesses_tab.dart';
import 'tabs/admin_host_verification_tab.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('Admin Console',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: AppColors.surface,
              elevation: 1,
            ),
      drawer: isDesktop ? null : _buildSidebar(isDrawer: true),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(isDrawer: false),
          Expanded(
            child: _buildCurrentTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar({bool isDrawer = false}) {
    final sidebarContent = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: isDrawer
            ? null
            : const Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.admin_panel_settings,
                color: Colors.white, size: 36),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Zeylo Admin',
            style:
                AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildNavItem(0, Icons.dashboard_rounded, 'Overview'),
          _buildNavItem(1, Icons.storefront_rounded, 'Business Approvals'),
          _buildNavItem(2, Icons.verified_user_rounded, 'Host Approvals'),
          _buildNavItem(3, Icons.flag_rounded, 'User Reports'),
          _buildNavItem(4, Icons.people_rounded, 'User Management'),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: AppColors.error),
            title: const Text('Exit Console',
                style: TextStyle(color: AppColors.error)),
            onTap: () => context.pop(),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );

    if (isDrawer) {
      return Drawer(
        backgroundColor: AppColors.surface,
        elevation: 0,
        child: sidebarContent,
      );
    }

    return SizedBox(
      width: 280,
      child: sidebarContent,
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(
          title,
          style: AppTypography.labelLarge.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: () {
          setState(() => _selectedIndex = index);
          final isDesktop = MediaQuery.of(context).size.width > 800;
          if (!isDesktop) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_selectedIndex) {
      case 0:
        return const AdminOverviewTab();
      case 1:
        return const AdminBusinessesTab();
      case 2:
        return const AdminHostVerificationTab();
      case 3:
        return const AdminReportsTab();
      case 4:
        return const AdminUsersTab();
      default:
        return const AdminOverviewTab();
    }
  }
}
