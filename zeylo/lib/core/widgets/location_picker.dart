import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as gc;
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../services/location_service.dart';

class LocationResult {
  final LatLng latLng;
  final String address;
  final String city;

  LocationResult({
    required this.latLng,
    required this.address,
    required this.city,
  });
}

/// A single search suggestion from geocoding
class _PlaceSuggestion {
  final String displayName;
  final double latitude;
  final double longitude;

  _PlaceSuggestion({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });
}

class ZeyloLocationPicker extends StatefulWidget {
  final LatLng initialPosition;
  final String? title;

  const ZeyloLocationPicker({
    super.key,
    this.initialPosition = const LatLng(6.9271, 79.8612),
    this.title = 'Select Location',
  });

  @override
  State<ZeyloLocationPicker> createState() => _ZeyloLocationPickerState();
}

class _ZeyloLocationPickerState extends State<ZeyloLocationPicker> {
  late GoogleMapController _mapController;
  late LatLng _currentPosition;
  String _address = 'Searching address...';
  String _city = '';
  bool _isSearching = false;
  List<_PlaceSuggestion> _suggestions = [];
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialPosition;
    _reverseGeocode(_currentPosition);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _reverseGeocode(LatLng position) async {
    try {
      final placemarks = await gc.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        setState(() {
          _address = [place.street, place.subLocality, place.locality]
              .where((s) => s != null && s.isNotEmpty)
              .join(', ');
          _city = place.locality ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _address = 'Address not found';
        });
      }
    }
  }

  /// Live search: called as user types, debounced by 500ms
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 3) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(query.trim());
    });
  }

  /// Fetch geocoded suggestions for the query
  Future<void> _fetchSuggestions(String query) async {
    if (!mounted) return;
    setState(() => _isSearching = true);
    try {
      final locations = await gc.locationFromAddress(query);
      final List<_PlaceSuggestion> results = [];

      for (final loc in locations.take(5)) {
        // Reverse geocode each result to get a readable address
        try {
          final placemarks = await gc.placemarkFromCoordinates(
            loc.latitude,
            loc.longitude,
          );
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            final display = [p.name, p.street, p.subLocality, p.locality, p.country]
                .where((s) => s != null && s.isNotEmpty)
                .toSet()
                .join(', ');
            results.add(_PlaceSuggestion(
              displayName: display,
              latitude: loc.latitude,
              longitude: loc.longitude,
            ));
          }
        } catch (_) {
          results.add(_PlaceSuggestion(
            displayName: '${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}',
            latitude: loc.latitude,
            longitude: loc.longitude,
          ));
        }
      }

      if (mounted) {
        setState(() {
          _suggestions = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
      }
    }
  }

  /// When user taps a suggestion
  void _selectSuggestion(_PlaceSuggestion suggestion) {
    final target = LatLng(suggestion.latitude, suggestion.longitude);
    _mapController.animateCamera(CameraUpdate.newLatLngZoom(target, 16));
    setState(() {
      _currentPosition = target;
      _suggestions = [];
      _searchController.text = suggestion.displayName;
    });
    _searchFocus.unfocus();
    _reverseGeocode(target);
  }

  Future<void> _goToCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentPosition();
      final target = LatLng(position.latitude, position.longitude);
      _mapController.animateCamera(CameraUpdate.newLatLngZoom(target, 16));
      setState(() {
        _currentPosition = target;
      });
      _reverseGeocode(target);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!, style: AppTypography.titleMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                LocationResult(
                  latLng: _currentPosition,
                  address: _address,
                  city: _city,
                ),
              );
            },
            child: Text('Confirm',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 14.0,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: (position) {
              _currentPosition = position.target;
            },
            onCameraIdle: () {
              _reverseGeocode(_currentPosition);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Center Pin
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 40,
              ),
            ),
          ),

          // Search Bar + Suggestions dropdown
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            right: AppSpacing.md,
            child: Column(
              children: [
                // Search field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          spreadRadius: 2),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    decoration: InputDecoration(
                      hintText: 'Search for a place...',
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.textSecondary),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _suggestions = []);
                                  },
                                )
                              : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),

                // Suggestions list
                if (_suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            spreadRadius: 1),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        final s = _suggestions[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.place,
                              color: AppColors.primary, size: 20),
                          title: Text(
                            s.displayName,
                            style: AppTypography.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _selectSuggestion(s),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Location display + Locate Me
          Positioned(
            bottom: AppSpacing.lg,
            left: AppSpacing.md,
            right: AppSpacing.md,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'locateMe',
                  onPressed: _goToCurrentLocation,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location,
                      color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          spreadRadius: 2),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _address,
                              style: AppTypography.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_city.isNotEmpty)
                              Text(
                                _city,
                                style: AppTypography.labelSmall
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
