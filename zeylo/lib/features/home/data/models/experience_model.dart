import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;
import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentSnapshot, Timestamp;
import '../../domain/entities/experience_entity.dart';

/// Model for Availability data
class AvailabilityModel {
  final String date;
  final String startTime;
  final String endTime;
  final int spotsLeft;

  AvailabilityModel({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.spotsLeft,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      date: json['date'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      spotsLeft: json['spotsLeft'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'spotsLeft': spotsLeft,
    };
  }

  Availability toEntity() {
    return Availability(
      date: date,
      startTime: startTime,
      endTime: endTime,
      spotsLeft: spotsLeft,
    );
  }
}

/// Model for GeoPoint data
class GeoPointModel {
  final double latitude;
  final double longitude;

  GeoPointModel({
    required this.latitude,
    required this.longitude,
  });

  factory GeoPointModel.fromJson(Map<String, dynamic> json) {
    return GeoPointModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  factory GeoPointModel.fromFirestore(cloud_firestore.GeoPoint geoPoint) {
    return GeoPointModel(
      latitude: geoPoint.latitude,
      longitude: geoPoint.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  GeoPoint toEntity() {
    return GeoPoint(
      latitude: latitude,
      longitude: longitude,
    );
  }
}

/// Model for Location data
class LocationModel {
  final String address;
  final String city;
  final String country;
  final GeoPointModel geoPoint;

  LocationModel({
    required this.address,
    required this.city,
    required this.country,
    required this.geoPoint,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      address: json['address'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      geoPoint: GeoPointModel.fromJson(
        json['geoPoint'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'city': city,
      'country': country,
      'geoPoint': geoPoint.toJson(),
    };
  }

  Location toEntity() {
    return Location(
      address: address,
      city: city,
      country: country,
      geoPoint: geoPoint.toEntity(),
    );
  }
}

/// Model for Experience data
class ExperienceModel {
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
  final int duration;
  final int maxGuests;
  final LocationModel location;
  final List<String> includes;
  final List<String> requirements;
  final List<String> languages;
  final double averageRating;
  final int reviewCount;
  final bool isActive;
  final bool isMysteryAvailable;
  final List<String> tags;
  final List<AvailabilityModel> availability;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isHostVerified;

  ExperienceModel({
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
    required this.isMysteryAvailable,
    required this.tags,
    required this.availability,
    required this.createdAt,
    required this.updatedAt,
    this.isHostVerified = false,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      shortDescription: json['shortDescription'] as String,
      hostId: json['hostId'] as String,
      hostName: json['hostName'] as String,
      hostPhotoUrl: json['hostPhotoUrl'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String,
      images: List<String>.from(json['images'] as List),
      coverImage: json['coverImage'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      duration: json['duration'] as int,
      maxGuests: json['maxGuests'] as int,
      location: LocationModel.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      includes: List<String>.from(json['includes'] as List),
      requirements: List<String>.from(json['requirements'] as List),
      languages: List<String>.from(json['languages'] as List),
      averageRating: (json['averageRating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      isActive: json['isActive'] as bool,
      isMysteryAvailable: json['isMysteryAvailable'] as bool? ?? false,
      tags: List<String>.from(json['tags'] as List? ?? []),
      availability: (json['availability'] as List?)
              ?.map(
                  (e) => AvailabilityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isHostVerified: json['isHostVerified'] as bool? ?? false,
    );
  }

  factory ExperienceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      return DateTime.now();
    }

    return ExperienceModel(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String,
      shortDescription: data['shortDescription'] as String,
      hostId: data['hostId'] as String,
      hostName: data['hostName'] as String,
      hostPhotoUrl: data['hostPhotoUrl'] as String,
      category: data['category'] as String,
      subcategory: data['subcategory'] as String,
      images: List<String>.from(data['images'] as List? ?? []),
      coverImage: data['coverImage'] as String,
      price: (data['price'] as num).toDouble(),
      currency: data['currency'] as String,
      duration: data['duration'] as int,
      maxGuests: data['maxGuests'] as int,
      location: LocationModel.fromJson(
        data['location'] as Map<String, dynamic>,
      ),
      includes: List<String>.from(data['includes'] as List? ?? []),
      requirements: List<String>.from(data['requirements'] as List? ?? []),
      languages: List<String>.from(data['languages'] as List? ?? []),
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      isMysteryAvailable: data['isMysteryAvailable'] as bool? ?? false,
      tags: List<String>.from(data['tags'] as List? ?? []),
      availability: (data['availability'] as List?)
              ?.map(
                  (e) => AvailabilityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
      isHostVerified: data['isHostVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'shortDescription': shortDescription,
      'hostId': hostId,
      'hostName': hostName,
      'hostPhotoUrl': hostPhotoUrl,
      'category': category,
      'subcategory': subcategory,
      'images': images,
      'coverImage': coverImage,
      'price': price,
      'currency': currency,
      'duration': duration,
      'maxGuests': maxGuests,
      'location': location.toJson(),
      'includes': includes,
      'requirements': requirements,
      'languages': languages,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'isActive': isActive,
      'isMysteryAvailable': isMysteryAvailable,
      'tags': tags,
      'availability': availability.map((e) => e.toJson()).toList(),
      'createdAt': cloud_firestore.Timestamp.fromDate(createdAt),
      'updatedAt': cloud_firestore.Timestamp.fromDate(updatedAt),
      'isHostVerified': isHostVerified,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'shortDescription': shortDescription,
      'hostId': hostId,
      'hostName': hostName,
      'hostPhotoUrl': hostPhotoUrl,
      'category': category,
      'subcategory': subcategory,
      'images': images,
      'coverImage': coverImage,
      'price': price,
      'currency': currency,
      'duration': duration,
      'maxGuests': maxGuests,
      'location': location.toJson(),
      'includes': includes,
      'requirements': requirements,
      'languages': languages,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'isActive': isActive,
      'isMysteryAvailable': isMysteryAvailable,
      'tags': tags,
      'availability': availability.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isHostVerified': isHostVerified,
    };
  }

  Experience toEntity() {
    return Experience(
      id: id,
      title: title,
      description: description,
      shortDescription: shortDescription,
      hostId: hostId,
      hostName: hostName,
      hostPhotoUrl: hostPhotoUrl,
      category: category,
      subcategory: subcategory,
      images: images,
      coverImage: coverImage,
      price: price,
      currency: currency,
      duration: duration,
      maxGuests: maxGuests,
      location: location.toEntity(),
      includes: includes,
      requirements: requirements,
      languages: languages,
      averageRating: averageRating,
      reviewCount: reviewCount,
      isActive: isActive,
      isMysteryAvailable: isMysteryAvailable,
      tags: tags,
      availability: availability.map((e) => e.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      isHostVerified: isHostVerified,
    );
  }
}
