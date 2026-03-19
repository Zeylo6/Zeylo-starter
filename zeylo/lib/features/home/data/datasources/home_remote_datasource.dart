import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/seed/seed_data.dart';
import '../models/category_model.dart';
import '../models/experience_model.dart';

/// Abstract remote data source for home feature
abstract class HomeRemoteDataSource {
  /// Get featured experiences from Firestore
  Future<List<ExperienceModel>> getFeaturedExperiences();

  /// Get experiences by category
  Future<List<ExperienceModel>> getExperiencesByCategory(String category);

  /// Get all active categories
  Future<List<CategoryModel>> getCategories();

  /// Search experiences by query
  Future<List<ExperienceModel>> searchExperiences(String query);

  /// Get nearby experiences
  Future<List<ExperienceModel>> getNearbyExperiences({
    required double latitude,
    required double longitude,
    required double radius,
  });

  /// Get single experience by ID
  Future<ExperienceModel> getExperienceById(String id);

  /// Get experience stream by ID
  Stream<ExperienceModel> getExperienceStream(String id);

  /// Get multiple experiences by IDs
  Future<List<ExperienceModel>> getExperiencesByIds(List<String> ids);

  /// Get all active experiences
  Future<List<ExperienceModel>> getAllExperiences();

  /// Watch featured experiences
  Stream<List<ExperienceModel>> watchFeaturedExperiences();

  /// Watch experiences by category
  Stream<List<ExperienceModel>> watchExperiencesByCategory(String category);
}

/// Implementation of HomeRemoteDataSource using Firestore
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseFirestore _firestore;

  HomeRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<ExperienceModel>> getFeaturedExperiences() async {
    try {
      // NOTE: Avoid orderBy('createdAt') with where('isActive') as it requires
      // a Firestore composite index. Sort client-side instead.
      final snapshot = await _firestore
          .collection('experiences')
          .where('isActive', isEqualTo: true)
          .limit(10)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final results = snapshot.docs
            .map((doc) => ExperienceModel.fromFirestore(doc))
            .toList();
        results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return results;
      }
      
      return [];
    } catch (e) {
      // Fallback to mock data on error (e.g. missing index)
      final mockData = await SeedData.getMockExperiences();
      return mockData
          .map((json) => ExperienceModel.fromJson(json as Map<String, dynamic>))
          .where((e) => e.isActive)
          .take(10)
          .toList();
    }
  }

  @override
  Future<List<ExperienceModel>> getExperiencesByCategory(
    String category,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('experiences')
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => ExperienceModel.fromFirestore(doc))
            .toList();
      }
      
      return [];
    } catch (e) {
      // Fallback
      final mockData = await SeedData.getMockExperiences();
      return mockData
          .map((json) => ExperienceModel.fromJson(json as Map<String, dynamic>))
          .where((e) => e.category == category && e.isActive)
          .toList();
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot =
          await _firestore.collection('categories').orderBy('order').get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => CategoryModel.fromFirestore(doc))
            .where((category) => category.isActive)
            .toList();
      }
      
      return [];
    } catch (e) {
      // Fallback
      final mockData = await SeedData.getMockCategories();
      return mockData
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
  }

  @override
  Future<List<ExperienceModel>> searchExperiences(String query) async {
    try {
      // Firestore doesn't have full-text search, so we fetch and filter
      final snapshot = await _firestore
          .collection('experiences')
          .where('isActive', isEqualTo: true)
          .get();

      final lowerQuery = query.toLowerCase();
      return snapshot.docs
          .map((doc) => ExperienceModel.fromFirestore(doc))
          .where((experience) =>
              experience.title.toLowerCase().contains(lowerQuery) ||
              experience.description.toLowerCase().contains(lowerQuery) ||
              experience.category.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ExperienceModel>> getNearbyExperiences({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    try {
      // Firestore doesn't have native geospatial queries without extensions
      // Fetch all experiences and filter by distance
      final snapshot = await _firestore
          .collection('experiences')
          .where('isActive', isEqualTo: true)
          .get();

      final experiences = snapshot.docs
          .map((doc) => ExperienceModel.fromFirestore(doc))
          .toList();

      // Filter by distance (simple implementation)
      return experiences.where((exp) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          exp.location.geoPoint.latitude,
          exp.location.geoPoint.longitude,
        );
        return distance <= radius;
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ExperienceModel>> getExperiencesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      // Firestore 'in' query is limited to 10 items. 
      // For simplicity in this starter, we fetch them one by one or in chunks if needed.
      // Here we'll fetch them individually to avoid the 10-item limit for now, 
      // though in production we should chunk the 'in' queries.
      final experiences = await Future.wait(
        ids.map((id) => getExperienceById(id)),
      );
      return experiences;
    } catch (e) {
      // Fallback
      final mockData = await SeedData.getMockExperiences();
      return mockData
          .map((json) => ExperienceModel.fromJson(json as Map<String, dynamic>))
          .where((e) => ids.contains(e.id))
          .toList();
    }
  }

  @override
  Future<List<ExperienceModel>> getAllExperiences() async {
    try {
      final snapshot = await _firestore
          .collection('experiences')
          .where('isActive', isEqualTo: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => ExperienceModel.fromFirestore(doc))
            .toList();
      }

      return [];
    } catch (e) {
      // Fallback
      final mockData = await SeedData.getMockExperiences();
      return mockData
          .map((json) => ExperienceModel.fromJson(json as Map<String, dynamic>))
          .where((e) => e.isActive)
          .toList();
    }
  }

  @override
  Future<ExperienceModel> getExperienceById(String id) async {
    try {
      final doc = await _firestore.collection('experiences').doc(id).get();
      if (!doc.exists) {
        throw Exception('Experience not found');
      }
      return ExperienceModel.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<ExperienceModel> getExperienceStream(String id) {
    return _firestore
        .collection('experiences')
        .doc(id)
        .snapshots()
        .map((doc) => ExperienceModel.fromFirestore(doc));
  }

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = (Math.sin(dLat / 2) * Math.sin(dLat / 2)) +
        (Math.cos(_degreesToRadians(lat1)) *
            Math.cos(_degreesToRadians(lat2)) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2));

    final c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  @override
  Stream<List<ExperienceModel>> watchFeaturedExperiences() {
    return _firestore
        .collection('experiences')
        .where('isActive', isEqualTo: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      final results = snapshot.docs
          .map((doc) => ExperienceModel.fromFirestore(doc))
          .toList();
      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return results;
    });
  }

  @override
  Stream<List<ExperienceModel>> watchExperiencesByCategory(String category) {
    return _firestore
        .collection('experiences')
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ExperienceModel.fromFirestore(doc))
          .toList();
    });
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180.0);
  }
}

class Math {
  static double sin(double x) => _sin(x);
  static double cos(double x) => _cos(x);
  static double atan2(double y, double x) => _atan2(y, x);
  static double sqrt(double x) => _sqrt(x);

  static double _sin(double x) {
    // Simple sin approximation
    x = x % (2 * 3.141592653589793);
    if (x < 0) x += 2 * 3.141592653589793;
    if (x > 3.141592653589793) x = 2 * 3.141592653589793 - x;
    const p = 0.166667;
    final x2 = x * x;
    return x * (1.0 - x2 * (p - x2 * p / 5.0) / 2.0);
  }

  static double _cos(double x) {
    return _sin(x + 3.141592653589793 / 2);
  }

  static double _atan2(double y, double x) {
    if (x > 0) {
      return _atan(y / x);
    } else if (x < 0 && y >= 0) {
      return _atan(y / x) + 3.141592653589793;
    } else if (x < 0 && y < 0) {
      return _atan(y / x) - 3.141592653589793;
    } else if (x == 0 && y > 0) {
      return 3.141592653589793 / 2;
    } else if (x == 0 && y < 0) {
      return -3.141592653589793 / 2;
    }
    return 0.0;
  }

  static double _atan(double x) {
    const p = 0.9999999988;
    return (3.141592653589793 / 4) * x -
        x * (x.abs() - 1) * (p + 0.1963 * x.abs());
  }

  static double _sqrt(double x) {
    if (x < 0) return double.nan;
    if (x == 0) return 0;
    double root = x / 2;
    for (int i = 0; i < 20; i++) {
      root = (root + x / root) / 2;
    }
    return root;
  }
}
