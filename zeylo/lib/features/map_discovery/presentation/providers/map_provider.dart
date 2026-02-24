import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Nearby item types
enum NearbyItemType {
  event,
  people,
  business,
}

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
  final String? icon; // Icon or color identifier
  final int? peopleCount;
  final String? actionLabel;

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
  });
}

/// Map filter type
enum MapFilterType {
  all,
  events,
  people,
  businesses,
}

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
  final List<NearbyItem> nearbyItems;
  final MapFilterType activeFilter;
  final bool isLoading;
  final String? error;
  final double? currentLat;
  final double? currentLng;

  const MapState({
    this.location = 'Colombo 05, Sri Lanka',
    this.nearbyItems = const [],
    this.activeFilter = MapFilterType.all,
    this.isLoading = false,
    this.error,
    this.currentLat,
    this.currentLng,
  });

  MapState copyWith({
    String? location,
    List<NearbyItem>? nearbyItems,
    MapFilterType? activeFilter,
    bool? isLoading,
    String? error,
    double? currentLat,
    double? currentLng,
  }) {
    return MapState(
      location: location ?? this.location,
      nearbyItems: nearbyItems ?? this.nearbyItems,
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
  MapNotifier() : super(const MapState());

  /// Set active filter
  void setFilter(MapFilterType filter) {
    state = state.copyWith(activeFilter: filter);
    _filterItems();
  }

  /// Load nearby items (mock implementation)
  Future<void> loadNearbyItems() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final mockItems = [
        NearbyItem(
          id: '1',
          title: 'Rooftop Party Tonight',
          subtitle: 'Live music & dancing',
          distance: '0.3 miles',
          time: '8:00 PM',
          details: '12 going',
          type: NearbyItemType.event,
          actionLabel: 'Join',
        ),
        NearbyItem(
          id: '2',
          title: 'Emma wants company',
          subtitle: 'Going to Mission District',
          distance: '0.5 miles',
          type: NearbyItemType.people,
          actionLabel: 'Connect',
        ),
        NearbyItem(
          id: '3',
          title: 'Luna Coffee Roasters',
          subtitle: 'Local cafe',
          distance: '0.2 miles',
          rating: '4.8★',
          type: NearbyItemType.business,
          actionLabel: 'Visit',
        ),
        NearbyItem(
          id: '4',
          title: 'Photography Meetup',
          subtitle: 'Dolores Park',
          distance: '0.8 miles',
          details: '6 members',
          type: NearbyItemType.event,
          actionLabel: 'Join',
        ),
      ];

      state = state.copyWith(
        nearbyItems: mockItems,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Filter items by type
  void _filterItems() {
    if (state.activeFilter == MapFilterType.all) {
      return;
    }

    final filteredItems = state.nearbyItems.where((item) {
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

    state = state.copyWith(nearbyItems: filteredItems);
  }

  /// Update location
  void updateLocation(String newLocation) {
    state = state.copyWith(location: newLocation);
  }
}

/// Map provider
final mapProvider = StateNotifierProvider<MapNotifier, MapState>(
  (ref) => MapNotifier(),
);
