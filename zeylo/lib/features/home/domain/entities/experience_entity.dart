import 'package:equatable/equatable.dart';

/// Represents the availability details for an experience
class Availability extends Equatable {
  final String date;
  final String startTime;
  final String endTime;
  final int spotsLeft;

  const Availability({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.spotsLeft,
  });

  @override
  List<Object?> get props => [date, startTime, endTime, spotsLeft];
}

/// Represents a geographic point with latitude and longitude
class GeoPoint {
  final double latitude;
  final double longitude;

  GeoPoint({
    required this.latitude,
    required this.longitude,
  });
}

/// Represents a location with address details
class Location extends Equatable {
  final String address;
  final String city;
  final String country;
  final GeoPoint geoPoint;

  const Location({
    required this.address,
    required this.city,
    required this.country,
    required this.geoPoint,
  });

  @override
  List<Object?> get props => [address, city, country, geoPoint];
}

/// Entity representing an experience offered on the Zeylo platform
class Experience extends Equatable {
  final String id;
  final String title;
  final String description;
  final String shortDescription;
  final String hostId;
  final String hostName;
  final String hostPhotoUrl;
  final String category;
  final String subcategory;
  final List<String> images;
  final String coverImage;
  final double price;
  final String currency;
  final int duration; // in minutes
  final int maxGuests;
  final Location location;
  final List<String> includes;
  final List<String> requirements;
  final List<String> languages;
  final double averageRating;
  final int reviewCount;
  final bool isActive;
  final List<String> tags;
  final List<Availability> availability;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Experience({
    required this.id,
    required this.title,
    required this.description,
    required this.shortDescription,
    required this.hostId,
    required this.hostName,
    required this.hostPhotoUrl,
    required this.category,
    required this.subcategory,
    required this.images,
    required this.coverImage,
    required this.price,
    required this.currency,
    required this.duration,
    required this.maxGuests,
    required this.location,
    required this.includes,
    required this.requirements,
    required this.languages,
    required this.averageRating,
    required this.reviewCount,
    required this.isActive,
    required this.tags,
    required this.availability,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        shortDescription,
        hostId,
        hostName,
        hostPhotoUrl,
        category,
        subcategory,
        images,
        coverImage,
        price,
        currency,
        duration,
        maxGuests,
        location,
        includes,
        requirements,
        languages,
        averageRating,
        reviewCount,
        isActive,
        tags,
        availability,
        createdAt,
        updatedAt,
      ];
}
