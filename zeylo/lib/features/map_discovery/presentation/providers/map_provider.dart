import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Nearby item types
enum NearbyItemType { event, people, business }

/// Nearby item model
class NearbyItem {
  final String id;
  final String title;
  final String subtitle;
  final String? distance;
  final String? time;
  final String? rating;
  final String? details;
  final NearbyItemType type;
  final String? icon;
  final int? peopleCount;
  final String? actionLabel;
  final double? latitude;
  final double? longitude;
  final int? commuteFromPreviousMinutes;
  final double? commuteDistanceKm;

  const NearbyItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.distance,
    this.time,
    this.rating,
    this.details,
    this.icon,
    this.peopleCount,
    this.actionLabel,
    this.latitude,
    this.longitude,
    this.commuteFromPreviousMinutes,
    this.commuteDistanceKm,
  });
}

/// Map filter type
enum MapFilterType { all, events, people, businesses }

extension MapFilterTypeX on MapFilterType {
  String get displayText {
    switch (this) {
      case MapFilterType.all:
        return 'All';
      case MapFilterType.events:
        return 'Events';
      case MapFilterType.people:
        return 'People';
      case MapFilterType.businesses:
        return 'Businesses';
    }
  }
}

/// Map state
class MapState {
  final String location;
  final List<NearbyItem> allNearbyItems;
  final List<NearbyItem> nearbyItems;
  final List<NearbyItem> routeItems;
  final MapFilterType activeFilter;
  final bool isLoading;
  final String? error;
  final double? currentLat;
  final double? currentLng;

  const MapState({
    this.location = 'Colombo 05, Sri Lanka',
    this.allNearbyItems = const [],
    this.nearbyItems = const [],
    this.routeItems = const [],
    this.activeFilter = MapFilterType.all,
    this.isLoading = false,
    this.error,
    this.currentLat,
    this.currentLng,
  });

  MapState copyWith({
    String? location,
    List<NearbyItem>? allNearbyItems,
    List<NearbyItem>? nearbyItems,
    List<NearbyItem>? routeItems,
    MapFilterType? activeFilter,
    bool? isLoading,
    String? error,
    double? currentLat,
    double? currentLng,
  }) {
    return MapState(
      location: location ?? this.location,
      allNearbyItems: allNearbyItems ?? this.allNearbyItems,
      nearbyItems: nearbyItems ?? this.nearbyItems,
      routeItems: routeItems ?? this.routeItems,
      activeFilter: activeFilter ?? this.activeFilter,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
    );
  }
}

/// Map notifier
class MapNotifier extends StateNotifier<MapState> {
  MapNotifier()
      : super(
          const MapState(
            currentLat: 6.9271,
            currentLng: 79.8612,
          ),
        );

  /// Set active filter
  void setFilter(MapFilterType filter) {
    state = state.copyWith(activeFilter: filter);
    _filterItems();
  }

  /// Load nearby items (mock implementation)
  Future<void> loadNearbyItems() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future.delayed(const Duration(seconds: 1));

      final mockItems = [
        const NearbyItem(
          id: '1',
          title: 'Rooftop Party Tonight',
          subtitle: 'Live music & dancing',
          time: '8:00 PM',
          details: '12 going',
          type: NearbyItemType.event,
          actionLabel: 'Join',
          latitude: 6.9199,
          longitude: 79.8580,
        ),
        const NearbyItem(
          id: '2',
          title: 'Emma wants company',
          subtitle: 'Going to Mission District',
          type: NearbyItemType.people,
          actionLabel: 'Connect',
          latitude: 6.9144,
          longitude: 79.8737,
        ),
        const NearbyItem(
          id: '3',
          title: 'Luna Coffee Roasters',
          subtitle: 'Local cafe',
          rating: '4.8★',
          type: NearbyItemType.business,
          actionLabel: 'Visit',
          latitude: 6.9060,
          longitude: 79.8562,
        ),
        const NearbyItem(
          id: '4',
          title: 'Photography Meetup',
          subtitle: 'Dolores Park',
          details: '6 members',
          type: NearbyItemType.event,
          actionLabel: 'Join',
          latitude: 6.9225,
          longitude: 79.8610,
        ),
      ];

      state = state.copyWith(
        allNearbyItems: mockItems,
        isLoading: false,
      );
      _filterItems();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Filter items by type
  void _filterItems() {
    final itemsWithDistance = state.allNearbyItems.map((item) {
      if (state.currentLat == null || state.currentLng == null) return item;
      if (item.latitude == null || item.longitude == null) return item;
      final distanceKm = _distanceKm(
        latitude1: state.currentLat!,
        longitude1: state.currentLng!,
        latitude2: item.latitude!,
        longitude2: item.longitude!,
      );
      return NearbyItem(
        id: item.id,
        title: item.title,
        subtitle: item.subtitle,
        distance: '${distanceKm.toStringAsFixed(1)} km',
        time: item.time,
        rating: item.rating,
        details: item.details,
        type: item.type,
        icon: item.icon,
        peopleCount: item.peopleCount,
        actionLabel: item.actionLabel,
        latitude: item.latitude,
        longitude: item.longitude,
      );
    }).toList();

    List<NearbyItem> filtered;
    if (state.activeFilter == MapFilterType.all) {
      filtered = itemsWithDistance;
    } else {
      filtered = itemsWithDistance.where((item) {
        switch (state.activeFilter) {
          case MapFilterType.events:
            return item.type == NearbyItemType.event;
          case MapFilterType.people:
            return item.type == NearbyItemType.people;
          case MapFilterType.businesses:
            return item.type == NearbyItemType.business;
          case MapFilterType.all:
            return true;
        }
      }).toList();
    }

    final route = _calculateRoute(filtered);
    state = state.copyWith(nearbyItems: filtered, routeItems: route);
  }

  /// Update location
  void updateLocation(String newLocation) {
    state = state.copyWith(location: newLocation);
  }

  List<NearbyItem> _calculateRoute(List<NearbyItem> items) {
    if (state.currentLat == null || state.currentLng == null) {
      return items;
    }

    final remaining = List<NearbyItem>.from(items);
    final route = <NearbyItem>[];
    double currentLat = state.currentLat!;
    double currentLng = state.currentLng!;

    while (remaining.isNotEmpty) {
      final nearestIndex = _findNearestIndex(
        remaining,
        latitude: currentLat,
        longitude: currentLng,
      );
      if (nearestIndex == -1) break;

      final next = remaining.removeAt(nearestIndex);
      final distance = (next.latitude == null || next.longitude == null)
          ? 0.0
          : _distanceKm(
              latitude1: currentLat,
              longitude1: currentLng,
              latitude2: next.latitude!,
              longitude2: next.longitude!,
            );
      final commute = distance > 0 ? _walkMinutes(distance) : null;
      final routeItem = NearbyItem(
        id: next.id,
        title: next.title,
        subtitle: next.subtitle,
        distance: '${distance.toStringAsFixed(1)} km',
        time: next.time,
        rating: next.rating,
        details: next.details,
        type: next.type,
        icon: next.icon,
        peopleCount: next.peopleCount,
        actionLabel: next.actionLabel,
        latitude: next.latitude,
        longitude: next.longitude,
        commuteDistanceKm: route.isEmpty ? null : distance,
        commuteFromPreviousMinutes: route.isEmpty ? null : commute,
      );

      route.add(routeItem);

      if (next.latitude != null && next.longitude != null) {
        currentLat = next.latitude!;
        currentLng = next.longitude!;
      }
    }

    return route;
  }

  int _findNearestIndex(
    List<NearbyItem> items, {
    required double latitude,
    required double longitude,
  }) {
    if (items.isEmpty) return -1;

    int bestIndex = -1;
    double bestDistance = double.infinity;

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.latitude == null || item.longitude == null) continue;

      final distance = _distanceKm(
        latitude1: latitude,
        longitude1: longitude,
        latitude2: item.latitude!,
        longitude2: item.longitude!,
      );
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }

    return bestIndex;
  }

  int _walkMinutes(double distanceKm) {
    if (distanceKm <= 0) return 2;
    return math.max(2, (distanceKm / 0.25).round().clamp(2, 180));
  }

  double _distanceKm({
    required double latitude1,
    required double longitude1,
    required double latitude2,
    required double longitude2,
  }) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(latitude2 - latitude1);
    final dLon = _toRadians(longitude2 - longitude1);
    final a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_toRadians(latitude1)) *
            math.cos(_toRadians(latitude2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2));
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double value) {
    return value * 3.141592653589793 / 180.0;
  }
}

/// Map provider
final mapProvider = StateNotifierProvider<MapNotifier, MapState>(
  (ref) => MapNotifier(),
);
