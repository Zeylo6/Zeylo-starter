import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/map_provider.dart';
import '../widgets/map_filter_tabs.dart';
import '../widgets/nearby_item_tile.dart';
import 'fullscreen_map_screen.dart';

/// Screen displaying nearby locations and activities on a map.
/// On desktop (≥800 px) renders a sidebar + full-height map layout.
/// On mobile keeps the original stacked layout.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  bool _sidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapProvider.notifier).loadNearbyItems();
    });
  }

  Set<Marker> _buildMarkers(MapState state) {
    return state.nearbyItems.map((item) {
      return Marker(
        markerId: MarkerId(item.id),
        position: LatLng(item.latitude ?? 0.0, item.longitude ?? 0.0),
        infoWindow: InfoWindow(title: item.title, snippet: item.subtitle),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          item.type == NearbyItemType.event
              ? BitmapDescriptor.hueViolet
              : item.type == NearbyItemType.people
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueBlue,
        ),
        onTap: () => _panToItem(item),
      );
    }).toSet();
  }

  // ─────────────────────────── DESKTOP BUILD ───────────────────────────

  Widget _buildDesktopLayout(MapState state) {
    return Row(
      children: [
        // ── Sidebar ──
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: _sidebarCollapsed ? 0 : 360,
          child: _sidebarCollapsed
              ? const SizedBox.shrink()
              : Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    border: Border(
                      right: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sidebar header
                      _buildSidebarHeader(state),
                      // Filter chips
                      MapFilterTabs(
                        filters: MapFilterType.values,
                        activeFilter: state.activeFilter,
                        onFilterChanged: (f) =>
                            ref.read(mapProvider.notifier).setFilter(f),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      // Nearby list
                      Expanded(child: _buildNearbyList(state)),
                    ],
                  ),
                ),
        ),

        // ── Map fills remaining space ──
        Expanded(
          child: Stack(
            children: [
              _buildFullMap(state),

              // Collapse / expand sidebar button
              Positioned(
                top: 16,
                left: 16,
                child: _buildSidebarToggle(),
              ),

              // My-location FAB
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  heroTag: 'map_locate',
                  onPressed: () =>
                      ref.read(mapProvider.notifier).updateCurrentLocation(),
                  backgroundColor: Colors.white,
                  elevation: 4,
                  child: const Icon(Icons.my_location,
                      color: AppColors.primary),
                ),
              ),

              // Fullscreen button
              Positioned(
                top: 16,
                right: 16,
                child: _buildMapOverlayButton(
                  icon: Icons.open_in_full_rounded,
                  label: 'Fullscreen',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullscreenMapScreen(
                        items: state.nearbyItems,
                        userLat: state.currentLat,
                        userLng: state.currentLng,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarHeader(MapState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.explore_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover Nearby',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    state.location,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.tune_rounded,
                    color: AppColors.textSecondary, size: 20),
                onPressed: () {},
                tooltip: 'Filters',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Location chip
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  'Current Location',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarToggle() {
    return GestureDetector(
      onTap: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 1),
          ],
        ),
        child: Icon(
          _sidebarCollapsed
              ? Icons.menu_open_rounded
              : Icons.close_rounded,
          size: 20,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildMapOverlayButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 1),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullMap(MapState state) {
    final markers = _buildMarkers(state);
    return GoogleMap(
      onMapCreated: (controller) => _mapController = controller,
      initialCameraPosition: CameraPosition(
        target: LatLng(
            state.currentLat ?? 6.9271, state.currentLng ?? 79.8612),
        zoom: 14.0,
      ),
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }

  // ─────────────────────────── MOBILE BUILD ────────────────────────────

  Widget _buildMobileLayout(MapState state) {
    return Column(
      children: [
        _buildMobileHeader(state),
        _buildMobileMap(state),
        MapFilterTabs(
          filters: MapFilterType.values,
          activeFilter: state.activeFilter,
          onFilterChanged: (f) =>
              ref.read(mapProvider.notifier).setFilter(f),
        ),
        Expanded(child: _buildNearbyList(state)),
      ],
    );
  }

  Widget _buildMobileHeader(MapState state) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(Icons.arrow_drop_down,
                color: AppColors.textPrimary, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(state.location,
                      style: AppTypography.titleMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                  Text('Current Location',
                      style: AppTypography.labelSmall
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.tune, color: AppColors.textPrimary, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileMap(MapState state) {
    final markers = _buildMarkers(state);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullscreenMapScreen(
            items: state.nearbyItems,
            userLat: state.currentLat,
            userLng: state.currentLng,
          ),
        ),
      ),
      child: Container(
        height: 220,
        margin: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GoogleMap(
                onMapCreated: (c) => _mapController = c,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      state.currentLat ?? 6.9271,
                      state.currentLng ?? 79.8612),
                  zoom: 14.0,
                ),
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: const Icon(Icons.open_in_full_rounded,
                    size: 16, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── SHARED ──────────────────────────────────

  Widget _buildNearbyList(MapState state) {
    if (state.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state.error != null) {
      return Center(
        child: Text('Error: ${state.error}',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
      );
    }
    if (state.nearbyItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_outlined,
                size: 56,
                color: AppColors.textSecondary.withOpacity(0.4)),
            const SizedBox(height: AppSpacing.lg),
            Text('No items nearby',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (state.routeItems.isNotEmpty) ...[
          _buildListSectionLabel('Suggested Route'),
          const SizedBox(height: AppSpacing.md),
          for (final item in state.routeItems)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: NearbyItemTile(
                item: item,
                onTap: () => _panToItem(item),
                onActionTap: () => _navigateToItem(item),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
        ],
        _buildListSectionLabel('Nearby Right Now'),
        const SizedBox(height: AppSpacing.md),
        for (final item in state.nearbyItems)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: NearbyItemTile(
              item: item,
              onTap: () => _panToItem(item),
              onActionTap: () => _navigateToItem(item),
            ),
          ),
      ],
    );
  }

  Widget _buildListSectionLabel(String label) {
    return Text(
      label,
      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
    );
  }

  // ─────────────────────────── MAIN BUILD ──────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 800) {
              return _buildDesktopLayout(state);
            }
            return Column(
              children: [
                Expanded(child: _buildMobileLayout(state)),
                _buildMobileBottomBar(),
              ],
            );
          },
        ),
      ),
      // Mobile FAB only
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 800) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 64),
            child: FloatingActionButton(
              heroTag: 'map_mobile_locate',
              onPressed: () =>
                  ref.read(mapProvider.notifier).updateCurrentLocation(),
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileBottomBar() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ZEYLO',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 1,
              ),
            ),
            const Icon(Icons.chat_bubble_outline,
                color: AppColors.textPrimary, size: 24),
          ],
        ),
      ),
    );
  }

  void _panToItem(NearbyItem item) {
    if (item.latitude != null &&
        item.longitude != null &&
        _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
            LatLng(item.latitude!, item.longitude!), 16),
      );
    }
  }

  Future<void> _navigateToItem(NearbyItem item) async {
    if (item.latitude == null || item.longitude == null) return;
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${item.latitude},${item.longitude}&travelmode=driving';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
