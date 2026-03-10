import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/map_provider.dart';
import '../widgets/map_filter_tabs.dart';
import '../widgets/nearby_item_tile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Screen displaying nearby locations and activities on a map
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  @override
  void initState() {
    super.initState();
    // Load nearby items on screen initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapProvider.notifier).loadNearbyItems();
    });
  }

  Set<Marker> _buildMarkers(MapState state) {
    return state.nearbyItems.map((item) {
      return Marker(
        markerId: MarkerId(item.id),
        position: LatLng(item.latitude ?? 0.0, item.longitude ?? 0.0),
        infoWindow: InfoWindow(
          title: item.title,
          snippet: item.subtitle,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          item.type == NearbyItemType.event
              ? BitmapDescriptor.hueViolet
              : item.type == NearbyItemType.people
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueBlue,
        ),
      );
    }).toSet();
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
          _buildMapPlaceholder(state),
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

  Widget _buildMapPlaceholder(MapState state) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('businesses').snapshots(),
      builder: (context, snapshot) {
        final businessDocs = snapshot.data?.docs ?? [];
        final businessMarkers = businessDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          // Basic coordinate parsing from location string (e.g. "6.92, 79.86")
          double lat = state.currentLat ?? 6.9271; 
          double lng = state.currentLng ?? 79.8612;
          try {
            final locStr = data['location']?.toString() ?? '';
            final parts = locStr.split(',');
            if (parts.length >= 2) {
              lat = double.parse(parts[0].trim());
              lng = double.parse(parts[1].trim());
            }
          } catch (_) {}
          
          return Marker(
            markerId: MarkerId('biz_${doc.id}'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: data['name'] ?? 'Local Business',
              snippet: data['enhanced_desc'] ?? 'Special offer inside!',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          );
        }).toSet();

        final allMarkers = _buildMarkers(state).union(businessMarkers);

        return Container(
          height: 250, // Increased height for better visibility
          margin: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(
                target: LatLng(state.currentLat ?? 6.9271, state.currentLng ?? 79.8612),
                zoom: 14.0,
              ),
              markers: allMarkers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),
        );
      }
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
        if (state.routeItems.isNotEmpty) ...[
          Text(
            'Suggested Route',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final item in state.routeItems)
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
          const SizedBox(height: AppSpacing.lg),
        ],
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
