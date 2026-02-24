import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/map_provider.dart';
import '../widgets/map_filter_tabs.dart';
import '../widgets/nearby_item_tile.dart';

/// Screen displaying nearby locations and activities on a map
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  @override
  void initState() {
    super.initState();
    // Load nearby items on screen initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapProvider.notifier).loadNearbyItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Location header
          _buildLocationHeader(context, state),
          // Map placeholder
          _buildMapPlaceholder(),
          // Filter tabs
          MapFilterTabs(
            filters: MapFilterType.values,
            activeFilter: state.activeFilter,
            onFilterChanged: (filter) {
              ref.read(mapProvider.notifier).setFilter(filter);
            },
          ),
          // Nearby items list
          Expanded(
            child: _buildNearbyList(state),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildLocationHeader(BuildContext context, MapState state) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Arrow icon
            Icon(
              Icons.arrow_drop_down,
              color: AppColors.textPrimary,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.sm),
            // Location text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.location,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Current Location',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Filter icon
            GestureDetector(
              onTap: () {
                // Handle filter/settings
              },
              child: Icon(
                Icons.tune,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Map background
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 48,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Map View',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Pin markers
          Positioned(
            left: 40,
            top: 40,
            child: _buildPin(Colors.purple), // Events - purple
          ),
          Positioned(
            right: 30,
            top: 60,
            child: _buildPin(Colors.green), // People - green
          ),
          Positioned(
            left: 60,
            bottom: 40,
            child: _buildPin(Colors.blue), // Businesses - blue
          ),
          Positioned(
            right: 50,
            bottom: 50,
            child: _buildPin(
              const Color(0xFFEC4899),
              size: 12, // Current user - smaller
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPin(Color color, {double size = 16}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyList(MapState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Text('Error: ${state.error}'),
      );
    }

    if (state.nearbyItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No items nearby',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'Nearby Right Now',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final item in state.nearbyItems)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: NearbyItemTile(
              item: item,
              onTap: () {
                // Navigate to item details
              },
              onActionTap: () {
                // Handle action
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ZEYLO Logo
            Text(
              'ZEYLO',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 1,
              ),
            ),
            // Chat icon
            GestureDetector(
              onTap: () {
                // Handle chat navigation
              },
              child: Icon(
                Icons.chat_bubble_outline,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
