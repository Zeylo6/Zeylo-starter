import 'dart:math' as math;

import '../../features/home/domain/entities/experience_entity.dart';

enum DiscoverySortMode { relevance, priceLow, priceHigh, rating, newest, smart }

class DiscoveryTripLeg {
  final Experience experience;
  final double distanceFromPreviousKm;
  final int travelMinutesFromPrevious;

  const DiscoveryTripLeg({
    required this.experience,
    required this.distanceFromPreviousKm,
    required this.travelMinutesFromPrevious,
  });
}

class DiscoveryUtils {
  static const double _defaultLatitude = 6.9271;
  static const double _defaultLongitude = 79.8612;

  static List<Experience> rankExperiences({
    required List<Experience> experiences,
    required DiscoverySortMode sortMode,
    String query = '',
    String? preferredCategory,
    double? minPrice,
    double? maxPrice,
    double? userLatitude,
    double? userLongitude,
  }) {
    final sorted = _fallbackSort(experiences, sortMode);
    final normalizedQuery = query.trim().toLowerCase();
    final now = DateTime.now();

    switch (sortMode) {
      case DiscoverySortMode.smart:
        sorted.sort((a, b) {
          final scoreB = _smartScore(
            b,
            normalizedQuery: normalizedQuery,
            preferredCategory: preferredCategory,
            now: now,
          );
          final scoreA = _smartScore(
            a,
            normalizedQuery: normalizedQuery,
            preferredCategory: preferredCategory,
            now: now,
          );
          return scoreB.compareTo(scoreA);
        });
        break;
      case DiscoverySortMode.relevance:
        if (normalizedQuery.isNotEmpty) {
          sorted.sort((a, b) {
            final scoreB = _relevanceScore(
              b,
              normalizedQuery: normalizedQuery,
              preferredCategory: preferredCategory,
              userLatitude: userLatitude ?? _defaultLatitude,
              userLongitude: userLongitude ?? _defaultLongitude,
              now: now,
            );
            final scoreA = _relevanceScore(
              a,
              normalizedQuery: normalizedQuery,
              preferredCategory: preferredCategory,
              userLatitude: userLatitude ?? _defaultLatitude,
              userLongitude: userLongitude ?? _defaultLongitude,
              now: now,
            );
            return scoreB.compareTo(scoreA);
          });
        }
        break;
      default:
        break;
    }

    return _applyPriceFilter(sorted, minPrice, maxPrice);
  }

  static List<DiscoveryTripLeg> buildTripPlan({
    required List<Experience> experiences,
    int maxStops = 4,
    int maxTotalMinutes = 300,
    String? budgetHint,
    String query = '',
    double? userLatitude,
    double? userLongitude,
  }) {
    if (experiences.isEmpty) return const [];

    final baseLat = userLatitude ?? _defaultLatitude;
    final baseLng = userLongitude ?? _defaultLongitude;
    final normalizedQuery = query.trim().toLowerCase();

    final pool = List<Experience>.from(experiences);
    if (normalizedQuery.isNotEmpty) {
      pool.sort((a, b) {
        final scoreB = _relevanceScore(
          b,
          normalizedQuery: normalizedQuery,
          preferredCategory: null,
          userLatitude: baseLat,
          userLongitude: baseLng,
          now: DateTime.now(),
        );
        final scoreA = _relevanceScore(
          a,
          normalizedQuery: normalizedQuery,
          preferredCategory: null,
          userLatitude: baseLat,
          userLongitude: baseLng,
          now: DateTime.now(),
        );
        return scoreB.compareTo(scoreA);
      });
    }

    final budgetLimit = _extractBudgetHint(budgetHint);
    if (budgetLimit != null) {
      pool.removeWhere((item) => item.price > budgetLimit);
    }

    final plan = <DiscoveryTripLeg>[];
    double currentLat = baseLat;
    double currentLng = baseLng;
    int remainingMinutes = maxTotalMinutes;

    while (plan.length < maxStops && pool.isNotEmpty) {
      final nearestIndex = _findNearestIndex(
        pool,
        latitude: currentLat,
        longitude: currentLng,
      );
      if (nearestIndex == -1) break;

      final candidate = pool.removeAt(nearestIndex);
      final distanceKm = _distanceKm(
        latitude1: currentLat,
        longitude1: currentLng,
        latitude2: candidate.location.geoPoint.latitude,
        longitude2: candidate.location.geoPoint.longitude,
      );
      final travelMinutes = _travelMinutesByRoad(distanceKm);
      final durationMinutes = candidate.duration > 0 ? candidate.duration : 90;
      final nextRemaining = remainingMinutes - travelMinutes - durationMinutes;

      if (plan.isNotEmpty && nextRemaining < 0) {
        break;
      }
      if (plan.isEmpty && (travelMinutes + durationMinutes) > remainingMinutes) {
        break;
      }

      remainingMinutes = math.max(nextRemaining, 0);
      plan.add(
        DiscoveryTripLeg(
          experience: candidate,
          distanceFromPreviousKm: distanceKm,
          travelMinutesFromPrevious: travelMinutes,
        ),
      );

      currentLat = candidate.location.geoPoint.latitude;
      currentLng = candidate.location.geoPoint.longitude;
    }

    return plan;
  }

  static List<Experience> _fallbackSort(
    List<Experience> experiences,
    DiscoverySortMode sortMode,
  ) {
    final sorted = List<Experience>.from(experiences);
    switch (sortMode) {
      case DiscoverySortMode.priceLow:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case DiscoverySortMode.priceHigh:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case DiscoverySortMode.rating:
        sorted.sort((a, b) => b.averageRating.compareTo(a.averageRating));
        break;
      case DiscoverySortMode.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case DiscoverySortMode.smart:
      case DiscoverySortMode.relevance:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return sorted;
  }

  static List<Experience> _applyPriceFilter(
    List<Experience> experiences,
    double? minPrice,
    double? maxPrice,
  ) {
    if (minPrice == null || maxPrice == null) return experiences;

    return experiences.where((experience) {
      return experience.price >= minPrice && experience.price <= maxPrice;
    }).toList();
  }

  static double _relevanceScore(
    Experience experience, {
    required String normalizedQuery,
    String? preferredCategory,
    required double userLatitude,
    required double userLongitude,
    required DateTime now,
  }) {
    final titleMatch = _termMatches(experience.title, normalizedQuery) * 5.0;
    final descriptionMatch =
        _termMatches(experience.description, normalizedQuery) * 3.0;
    final categoryMatch =
        experience.category.toLowerCase() == normalizedQuery ? 6.0 : 0.0;
    final matchCategory =
        preferredCategory != null &&
                experience.category.toLowerCase() ==
                    preferredCategory.toLowerCase()
            ? 2.5
            : 0.0;
    final quality = (experience.averageRating * 1.8) +
        (experience.reviewCount > 0
            ? 3 * (1 + (math.log(1 + experience.reviewCount) / math.log(10)))
            : 0.0);
    final recencyHours = now.difference(experience.updatedAt).abs().inHours.toDouble();
    final recency = 12 / (1 + recencyHours / 24.0);
    final distanceKm = _distanceKm(
      latitude1: userLatitude,
      longitude1: userLongitude,
      latitude2: experience.location.geoPoint.latitude,
      longitude2: experience.location.geoPoint.longitude,
    );
    final distanceScore = 20 / (1 + distanceKm);

    return titleMatch +
        descriptionMatch +
        categoryMatch +
        matchCategory +
        quality +
        recency +
        distanceScore;
  }

  static double _smartScore(
    Experience experience, {
    required String normalizedQuery,
    required String? preferredCategory,
    required DateTime now,
  }) {
    final quality = (experience.averageRating * 2.0) +
        (experience.reviewCount > 0
            ? 3 * (1 + (math.log(1 + experience.reviewCount) / math.log(10)))
            : 0.0);
    final trend = experience.isMysteryAvailable ? 4.0 : 0.0;
    final recency = 18 / (1 + now.difference(experience.updatedAt).abs().inDays);
    final category = preferredCategory != null &&
            experience.category.toLowerCase() ==
                preferredCategory.toLowerCase()
        ? 4.5
        : 0.0;
    final match = normalizedQuery.isNotEmpty
        ? (_termMatches(experience.title, normalizedQuery) +
                _termMatches(experience.tags.join(' '), normalizedQuery)) *
            2.0
        : 0.0;
    return quality + trend + recency + category + match;
  }

  static double _termMatches(String value, String normalizedQuery) {
    if (normalizedQuery.isEmpty) return 0;
    final terms = normalizedQuery.split(RegExp(r'\s+')).where((term) => term.isNotEmpty);
    if (terms.isEmpty) return 0;
    final source = value.toLowerCase();
    return terms.where((term) => source.contains(term)).length.toDouble();
  }

  static double _distanceKm({
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

  static int _findNearestIndex(
    List<Experience> items, {
    required double latitude,
    required double longitude,
  }) {
    if (items.isEmpty) return -1;
    int bestIndex = -1;
    double bestDistance = double.infinity;
    for (var i = 0; i < items.length; i++) {
      final candidate = items[i];
      final distance = _distanceKm(
        latitude1: latitude,
        longitude1: longitude,
        latitude2: candidate.location.geoPoint.latitude,
        longitude2: candidate.location.geoPoint.longitude,
      );
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  static int _travelMinutesByRoad(double distanceKm) {
    if (distanceKm <= 0) return 2;
    final walkMinutes = (distanceKm / 0.25).round().clamp(2, 180);
    return walkMinutes;
  }

  static int? _extractBudgetHint(String? budgetHint) {
    if (budgetHint == null || budgetHint.isEmpty) return null;
    final match = RegExp(r'(\d+)').firstMatch(budgetHint);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  static double _toRadians(double value) {
    return value * 3.141592653589793 / 180.0;
  }
}
