import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/ai_service.dart';
import '../models/mystery_model.dart';

/// Abstract data source for mystery bookings
abstract class MysteryDataSource {
  Future<MysteryModel> createMystery(MysteryModel mystery);
  Future<List<MysteryModel>> getMysteries(String userId);
  Future<MysteryModel> getMysteryById(String mysteryId);
  Future<MysteryModel> updateMystery(MysteryModel mystery);
  Future<void> deleteMystery(String mysteryId);

  Future<MysteryMatchResult> matchAndBookMystery({
    required String mysteryId,
    required String userId,
    required String location,
    required String date,
    required String time,
    required double budgetMin,
    required double budgetMax,
    required String experienceType,
  });
}

/// Result returned from mystery matching
class MysteryMatchResult {
  final bool matched;
  final String? bookingId;
  final String? teaserDescription;
  final String? vibe;
  final String? preparationNotes;
  final String? reason;
  final String? message;

  const MysteryMatchResult({
    required this.matched,
    this.bookingId,
    this.teaserDescription,
    this.vibe,
    this.preparationNotes,
    this.reason,
    this.message,
  });
}

/// Firebase + Express backend implementation.
class MysteryDataSourceImpl implements MysteryDataSource {
  final FirebaseFirestore firestore;
  final AIService aiService;

  static const String _mysteryCollection = 'mysteries';

  MysteryDataSourceImpl({
    required this.firestore,
    required this.aiService,
  });

  // ──────────────────────────────────────────────────────────────────────────
  // CRUD
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<MysteryModel> createMystery(MysteryModel mystery) async {
    try {
      // Save to Firestore — do NOT call aiService here.
      // AI teaser content is set AFTER matching succeeds.
      final docRef = await firestore
          .collection(_mysteryCollection)
          .add(mystery.toFirestore());
      return mystery.copyWith(id: docRef.id);
    } on FirebaseException catch (e) {
      throw Exception('Failed to create mystery: ${e.message}');
    }
  }

  @override
  Future<List<MysteryModel>> getMysteries(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection(_mysteryCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => MysteryModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to get mysteries: ${e.message}');
    }
  }

  @override
  Future<MysteryModel> getMysteryById(String mysteryId) async {
    try {
      final doc = await firestore
          .collection(_mysteryCollection)
          .doc(mysteryId)
          .get();
      if (!doc.exists) throw Exception('Mystery not found');
      return MysteryModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception('Failed to get mystery: ${e.message}');
    }
  }

  @override
  Future<MysteryModel> updateMystery(MysteryModel mystery) async {
    try {
      await firestore
          .collection(_mysteryCollection)
          .doc(mystery.id)
          .update(mystery.toFirestore());
      return mystery;
    } on FirebaseException catch (e) {
      throw Exception('Failed to update mystery: ${e.message}');
    }
  }

  @override
  Future<void> deleteMystery(String mysteryId) async {
    try {
      await firestore.collection(_mysteryCollection).doc(mysteryId).delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete mystery: ${e.message}');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // MATCHING — Cloud Function first, client-side fallback
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<MysteryMatchResult> matchAndBookMystery({
    required String mysteryId,
    required String userId,
    required String location,
    required String date,
    required String time,
    required double budgetMin,
    required double budgetMax,
    required String experienceType,
  }) async {
    // Try Backend API First
    try {
      final payload = {
        'mysteryId': mysteryId,
        'userId': userId,
        'location': location,
        'date': date,
        'time': time,
        'budgetMin': budgetMin,
        'budgetMax': budgetMax,
        'experienceType': experienceType,
      };
      
      final data = await aiService.matchAndBookMystery(payload);
      
      if (data['matched'] == true) {
        return MysteryMatchResult(
          matched: true,
          bookingId: data['bookingId'] as String?,
          teaserDescription: data['teaserDescription'] as String?,
          vibe: data['vibe'] as String?,
          preparationNotes: data['preparationNotes'] as String?,
        );
      }
      return MysteryMatchResult(
        matched: false,
        reason: data['reason'] as String?,
        message: data['message'] as String? ??
            'No experiences found matching your preferences.',
      );
    } catch (e) {
      debugPrint('Backend matching API failed: $e. Using client-side matching fallback.');
    }

    // Client-side fallback
    return _clientSideMatchAndBook(
      mysteryId: mysteryId,
      userId: userId,
      location: location,
      date: date,
      time: time,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      experienceType: experienceType,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // CLIENT-SIDE MATCHING
  //
  // REQUIRED: price <= budgetMax  AND  at least one location word matches
  // BONUS:    price >= budgetMin  (+3)
  //           strong location match (+5) or word match (+2 each)
  //           category match (+4)
  //
  // Category is NEVER a hard filter — only a score bonus.
  // Top 5 scoring matches are shuffled so the pick feels mysterious.
  // ──────────────────────────────────────────────────────────────────────────

  // ──────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  /// Safely converts any Firestore value to a String.
  String? _safeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    if (value is Map) return null;
    if (value is List) return null;
    return value.toString();
  }

  /// Extracts a searchable location string from a Firestore location field.
  /// The location field can be:
  ///   - A plain String: "Colombo"
  ///   - A Map: {address: "...", city: "Colombo", country: "Sri Lanka", geoPoint: {...}}
  /// Returns a combined string of city + address + country for fuzzy matching.
  String _extractLocation(dynamic rawLocation) {
    if (rawLocation == null) return '';
    if (rawLocation is String) return rawLocation.toLowerCase().trim();
    if (rawLocation is Map) {
      final city    = (rawLocation['city']    ?? '').toString();
      final address = (rawLocation['address'] ?? '').toString();
      final country = (rawLocation['country'] ?? '').toString();
      return '$city $address $country'.toLowerCase().trim();
    }
    return rawLocation.toString().toLowerCase().trim();
  }

  /// Extracts first image URL from coverImage (String) or images (List).
  String _extractCoverImage(Map<String, dynamic> data) {
    final cover = data['coverImage'];
    if (cover is String && cover.isNotEmpty) return cover;
    final images = data['images'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is String) return first;
    }
    return '';
  }

  Future<MysteryMatchResult> _clientSideMatchAndBook({
    required String mysteryId,
    required String userId,
    required String location,
    required String date,
    required String time,
    required double budgetMin,
    required double budgetMax,
    required String experienceType,
  }) async {
    try {
      // 1. Fetch ALL experiences — filter in memory.
      //    Do NOT use .where() on isActive or isMysteryAvailable because
      //    many existing experiences may not have those fields set,
      //    which would cause the query to return zero results.
      final snapshot = await firestore
          .collection('experiences')
          .get();

      if (snapshot.docs.isEmpty) {
        return const MysteryMatchResult(
          matched: false,
          reason: 'no_experiences',
          message: 'No experiences found. Please try again later.',
        );
      }

      // 2. Prepare location words for fuzzy matching
      final userLocation = location.toLowerCase().trim();
      final locationWords = userLocation
          .split(RegExp(r'[\s,]+'))
          .where((w) => w.length > 2)
          .toList();

      // 3. Score every experience
      final scored = <MapEntry<
          QueryDocumentSnapshot<Map<String, dynamic>>, int>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        // Skip experiences explicitly marked as inactive (default: treat as active)
        final isActive = data['isActive'];
        if (isActive == false) continue;

        final price = (data['price'] as num?)?.toDouble() ?? 0.0;
        int score = 0;

        // ── PRICE (REQUIRED) ───────────────────────────────────────────────
        if (price > budgetMax) continue; // hard disqualify — too expensive
        if (price >= budgetMin) score += 3; // within full range — bonus

        // ── LOCATION (REQUIRED if user typed something) ────────────────────
        final expLocation =
            _extractLocation(data['location']);
        final expTitle =
            (_safeString(data['title']) ?? '').toLowerCase();
        final expDesc =
            (_safeString(data['description']) ?? '').toLowerCase();

        if (userLocation.isNotEmpty) {
          bool locationMatched = false;

          // Full substring match
          if (expLocation.contains(userLocation) ||
              userLocation.contains(expLocation)) {
            score += 5;
            locationMatched = true;
          } else {
            // Word-level fuzzy — any word from user location found anywhere
            for (final word in locationWords) {
              if (expLocation.contains(word) ||
                  expTitle.contains(word) ||
                  expDesc.contains(word)) {
                score += 2;
                locationMatched = true;
              }
            }
          }

          // No location word matched at all — skip
          if (!locationMatched) continue;
        }

        // ── CATEGORY (BONUS only — never disqualifies) ────────────────────
        if (experienceType != 'surpriseMe') {
          final category =
              (_safeString(data['category']) ?? '').toLowerCase();
          final Map<String, List<String>> keywords = {
            'adventure': [
              'adventure', 'nature', 'outdoor', 'sport',
              'hiking', 'trekking', 'extreme'
            ],
            'foodAndDrink': [
              'food', 'drink', 'culinary', 'dining',
              'restaurant', 'cooking', 'cuisine', 'chef'
            ],
            'artsAndCulture': [
              'art', 'culture', 'music', 'craft',
              'gallery', 'theatre', 'heritage', 'dance'
            ],
          };
          final kwList = keywords[experienceType] ?? [];
          for (final kw in kwList) {
            if (category.contains(kw) ||
                expTitle.contains(kw) ||
                expDesc.contains(kw)) {
              score += 4;
              break;
            }
          }
        }

        scored.add(MapEntry(doc, score));
      }

      // 4. No experiences passed the filters
      if (scored.isEmpty) {
        return const MysteryMatchResult(
          matched: false,
          reason: 'no_match',
          message:
              'No experiences found in your area within your budget. Try a different location or increase your budget.',
        );
      }

      // 5. Sort by score, shuffle top 5 for mystery variety
      scored.sort((a, b) => b.value.compareTo(a.value));
      final topMatches = scored.take(5).map((e) => e.key).toList();
      topMatches.shuffle();
      final selectedDoc = topMatches.first;
      final expData = selectedDoc.data();

      // Safe field extraction — some fields may be Maps or other types
      // if the Firestore document has nested objects. We convert to string safely.
      final experienceTitle =
          _safeString(expData['title']) ?? 'Mystery Experience';
      final experienceCoverImage = _extractCoverImage(expData);
      final hostId = _safeString(expData['hostId']) ?? '';
      final price = (expData['price'] as num?)?.toDouble() ?? 0.0;
      // Extract plain city string for any logging/notifications
      final experienceLocation = _extractLocation(expData['location']);

      // 6. Parse booking date from dd/mm
      DateTime bookingDate = DateTime.now().add(const Duration(days: 7));
      final dateParts = date.split('/');
      if (dateParts.length == 2) {
        final day = int.tryParse(dateParts[0]) ?? 1;
        final month = int.tryParse(dateParts[1]) ?? 1;
        final year = DateTime.now().year;
        final parsed = DateTime(year, month, day);
        bookingDate = parsed.isAfter(DateTime.now())
            ? parsed
            : DateTime(year + 1, month, day);
      }

      // 7. Map time preference to start time
      final String startTime;
      switch (time) {
        case 'afternoon':
          startTime = '12:00 PM';
          break;
        case 'evening':
          startTime = '05:00 PM';
          break;
        default:
          startTime = '09:00 AM';
      }

      // 8. Create booking in Firestore
      final bookingRef = await firestore.collection('bookings').add({
        'experienceId': selectedDoc.id,
        'experienceTitle': experienceTitle,
        'experienceCoverImage': experienceCoverImage,
        'userId': userId,
        'hostId': hostId,
        'date': Timestamp.fromDate(bookingDate),
        'startTime': startTime,
        'guests': 1,
        'totalPrice': price,
        'status': 'mystery_pending',
        'paymentStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isRatedByHost': false,
        'isRatedBySeeker': false,
        'isEarningsCollected': false,
        'isMystery': true,
        'mysteryId': mysteryId,
      });

      // 9. Update mystery doc — matched status + teaser
      await firestore
          .collection(_mysteryCollection)
          .doc(mysteryId)
          .update({
        'status': 'matched',
        'matchedExperienceId': selectedDoc.id,
        'teaserDescription':
            'Something extraordinary is waiting for you. Prepare for an experience you will never forget!',
        'vibe': '✨ Mystery Vibes',
        'preparationNotes':
            'Wear comfortable clothes and bring your sense of adventure!',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 10. Notify host
      await firestore.collection('activities').add({
        'userId': hostId,
        'title': 'New Mystery Booking 🎁',
        'message':
            'A mystery seeker matched to your experience "$experienceTitle".',
        'type': 'mystery_booking',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'bookingId': bookingRef.id,
      });

      // 11. Notify seeker
      await firestore.collection('activities').add({
        'userId': userId,
        'title': 'Mystery Booked! 🎁',
        'message':
            'Your surprise adventure is set! Details revealed 48 hours before.',
        'type': 'mystery_booked',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'bookingId': bookingRef.id,
      });

      return const MysteryMatchResult(
        matched: true,
        teaserDescription:
            'Something extraordinary is waiting for you. Prepare for an experience you will never forget!',
        vibe: '✨ Mystery Vibes',
        preparationNotes:
            'Wear comfortable clothes and bring your sense of adventure!',
      );
    } catch (e) {
      throw Exception('Mystery matching failed: $e');
    }
  }
}