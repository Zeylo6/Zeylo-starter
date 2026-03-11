import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/services/location_service.dart';
import '../providers/map_provider.dart';

/// Full-screen map for exploring experiences and businesses with route generation
class FullscreenMapScreen extends ConsumerStatefulWidget {
  final List<NearbyItem> items;
  final double? userLat;
  final double? userLng;

  const FullscreenMapScreen({
    super.key,
    required this.items,
    this.userLat,
    this.userLng,
  });

  @override
  ConsumerState<FullscreenMapScreen> createState() =>
      _FullscreenMapScreenState();
}

class _FullscreenMapScreenState extends ConsumerState<FullscreenMapScreen> {
  GoogleMapController? _mapController;
  bool _routeGenerated = false;
  List<NearbyItem> _orderedRoute = [];
  Set<Polyline> _polylines = {};

  double get _startLat => widget.userLat ?? 6.9271;
  double get _startLng => widget.userLng ?? 79.8612;

  @override
  void initState() {
    super.initState();
    _orderedRoute = widget.items;
  }

  /// Build markers — numbered if route is generated
  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // User location marker
    markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(_startLat, _startLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'You are here'),
      ),
    );

    final items = _routeGenerated ? _orderedRoute : widget.items;
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.latitude == null || item.longitude == null) continue;

      markers.add(
        Marker(
          markerId: MarkerId(item.id),
          position: LatLng(item.latitude!, item.longitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            item.type == NearbyItemType.event
                ? BitmapDescriptor.hueViolet
                : BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(
            title: _routeGenerated ? '${i + 1}. ${item.title}' : item.title,
            snippet: item.subtitle,
          ),
          onTap: () {
            _showItemSheet(item, _routeGenerated ? i + 1 : null);
          },
        ),
      );
    }

    return markers;
  }

  /// Generate the best route: nearest-neighbor ordering + polylines
  void _generateRoute() {
    final items = widget.items
        .where((i) => i.latitude != null && i.longitude != null)
        .toList();
    if (items.isEmpty) return;

    // Nearest-neighbor ordering starting from user location
    final remaining = List<NearbyItem>.from(items);
    final route = <NearbyItem>[];
    double curLat = _startLat;
    double curLng = _startLng;

    while (remaining.isNotEmpty) {
      int bestIdx = 0;
      double bestDist = double.infinity;
      for (int i = 0; i < remaining.length; i++) {
        final d = _haversine(
            curLat, curLng, remaining[i].latitude!, remaining[i].longitude!);
        if (d < bestDist) {
          bestDist = d;
          bestIdx = i;
        }
      }
      final next = remaining.removeAt(bestIdx);
      route.add(next);
      curLat = next.latitude!;
      curLng = next.longitude!;
    }

    // Build polylines
    final points = <LatLng>[LatLng(_startLat, _startLng)];
    for (final item in route) {
      points.add(LatLng(item.latitude!, item.longitude!));
    }

    setState(() {
      _orderedRoute = route;
      _routeGenerated = true;
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: points,
          color: AppColors.primary,
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      };
    });

    // Zoom to fit all points
    if (points.length >= 2 && _mapController != null) {
      final bounds = _boundsFromPoints(points);
      _mapController!
          .animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
    }
  }

  LatLngBounds _boundsFromPoints(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  double _haversine(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * 3.141592653589793 / 180.0;
    final dLng = (lng2 - lng1) * 3.141592653589793 / 180.0;
    final lat1Rad = lat1 * 3.141592653589793 / 180.0;
    final lat2Rad = lat2 * 3.141592653589793 / 180.0;
    final a = _sinSq(dLat / 2) +
        _cosV(lat1Rad) * _cosV(lat2Rad) * _sinSq(dLng / 2);
    return r * 2 * _atan2V(_sqrtV(a), _sqrtV(1 - a));
  }
  
  // Use Platform-independent math (avoids importing dart:math for minimal funcs)
  static double _sinSq(double x) { final s = _sinV(x); return s * s; }
  static double _sinV(double x) { double t = x, s = x; for(int i=1;i<=10;i++){t*=-x*x/((2*i)*(2*i+1));s+=t;} return s; }
  static double _cosV(double x) => _sinV(x + 3.141592653589793 / 2);
  static double _sqrtV(double x) { if(x<=0)return 0; double g=x/2; for(int i=0;i<20;i++){g=(g+x/g)/2;} return g; }
  static double _atan2V(double y, double x) {
    if(x>0) return _atanA(y/x);
    if(x<0&&y>=0) return _atanA(y/x)+3.141592653589793;
    if(x<0&&y<0) return _atanA(y/x)-3.141592653589793;
    if(x==0&&y>0) return 3.141592653589793/2;
    if(x==0&&y<0) return -3.141592653589793/2;
    return 0;
  }
  static double _atanA(double x) {
    if(x.abs()<=1){double t=x,s=x;for(int i=1;i<=15;i++){t*=-x*x;s+=t/(2*i+1);}return s;}
    return (x>0?1:-1)*(3.141592653589793/2-_atanA(1/x));
  }

  /// Launch native Google Maps with multi-stop route
  Future<void> _launchNavigation() async {
    if (_orderedRoute.isEmpty) return;

    final origin = '$_startLat,$_startLng';
    final destination =
        '${_orderedRoute.last.latitude},${_orderedRoute.last.longitude}';

    // Build waypoints (all stops except last)
    final waypoints = _orderedRoute
        .take(_orderedRoute.length - 1)
        .map((i) => '${i.latitude},${i.longitude}')
        .join('|');

    String url;
    if (waypoints.isNotEmpty) {
      url =
          'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&waypoints=$waypoints&travelmode=driving';
    } else {
      url =
          'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving';
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  /// Launch navigation to a single item
  Future<void> _launchSingleNavigation(NearbyItem item) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${item.latitude},${item.longitude}&travelmode=driving';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _showItemSheet(NearbyItem item, int? routeNumber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                // Number badge if route
                if (routeNumber != null)
                  Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$routeNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: (item.type == NearbyItemType.business
                            ? Colors.blue
                            : AppColors.primary)
                        .withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.type == NearbyItemType.business
                        ? Icons.business
                        : Icons.event,
                    color: item.type == NearbyItemType.business
                        ? Colors.blue
                        : AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: AppTypography.titleMedium),
                      Text(item.subtitle,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Distance & rating
            Row(
              children: [
                if (item.rating != null) ...[
                  const Icon(Icons.star, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(item.rating!, style: AppTypography.labelSmall),
                  const SizedBox(width: AppSpacing.md),
                ],
                if (item.distance != null) ...[
                  const Icon(Icons.directions_walk,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(item.distance!,
                      style: AppTypography.labelSmall),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _launchSingleNavigation(item);
                    },
                    icon: const Icon(Icons.navigation_rounded, size: 18),
                    label: const Text('Navigate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen Google Map
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              // Zoom to fit all markers
              if (widget.items.isNotEmpty) {
                final points = widget.items
                    .where((i) => i.latitude != null && i.longitude != null)
                    .map((i) => LatLng(i.latitude!, i.longitude!))
                    .toList();
                points.add(LatLng(_startLat, _startLng));
                if (points.length >= 2) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngBounds(
                          _boundsFromPoints(points), 60),
                    );
                  });
                }
              }
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(_startLat, _startLng),
              zoom: 13.0,
            ),
            markers: _buildMarkers(),
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Route info bar (shown when route is generated)
          if (_routeGenerated)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 72,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        spreadRadius: 1),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.route, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_orderedRoute.length} stops optimized',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _routeGenerated = false;
                          _polylines = {};
                          _orderedRoute = widget.items;
                        });
                      },
                      child: const Icon(Icons.close,
                          size: 18, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),

      // FABs
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Locate me
          FloatingActionButton(
            heroTag: 'fs_locate',
            onPressed: () async {
              try {
                final pos = await LocationService.getCurrentPosition();
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                      LatLng(pos.latitude, pos.longitude), 15),
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Location error: $e')),
                  );
                }
              }
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.my_location, color: AppColors.primary),
          ),
          const SizedBox(height: 12),

          // Generate route / Start navigation
          FloatingActionButton.extended(
            heroTag: 'fs_route',
            onPressed: _routeGenerated ? _launchNavigation : _generateRoute,
            backgroundColor: AppColors.primary,
            icon: Icon(
              _routeGenerated ? Icons.navigation_rounded : Icons.route,
              color: Colors.white,
            ),
            label: Text(
              _routeGenerated ? 'Start Navigation' : 'Best Route',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
