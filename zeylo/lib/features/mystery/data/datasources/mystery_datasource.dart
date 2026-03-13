import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/ai_service.dart';
import '../models/mystery_model.dart';

/// Abstract data source for mystery bookings
///
/// Defines the contract for mystery data operations
abstract class MysteryDataSource {
  /// Create a new mystery booking
  Future<MysteryModel> createMystery(MysteryModel mystery);

  /// Get all mysteries for a user
  Future<List<MysteryModel>> getMysteries(String userId);

  /// Get a single mystery by ID
  Future<MysteryModel> getMysteryById(String mysteryId);

  /// Update a mystery
  Future<MysteryModel> updateMystery(MysteryModel mystery);

  /// Delete a mystery
  Future<void> deleteMystery(String mysteryId);

  /// Find a matching experience for a mystery
  Future<String?> matchMysteryExperience(MysteryModel mystery);
}

/// Firebase implementation of mystery data source
class MysteryDataSourceImpl implements MysteryDataSource {
  /// Firestore instance
  final FirebaseFirestore firestore;

  /// AI service instance
  final AIService aiService;

  /// Collection path for mysteries
  static const String _mysteryCollection = 'mysteries';

  MysteryDataSourceImpl({
    required this.firestore,
    required this.aiService,
  });

  @override
  Future<MysteryModel> createMystery(MysteryModel mystery) async {
    try {
      // 1. Generate AI mystery details
      MysteryModel mysteryToCreate = mystery;
      try {
        final aiParams = {
          'location': mystery.location,
          'date': mystery.date,
          'time': mystery.time.label,
          'budget': '\$${mystery.budgetMin.toStringAsFixed(0)} - \$${mystery.budgetMax.toStringAsFixed(0)}',
          'type': mystery.experienceType.label,
        };

        final aiResult = await aiService.generateSurprise(aiParams);
        
        mysteryToCreate = mystery.copyWith(
          teaserDescription: aiResult['teaserDescription'],
          vibe: aiResult['vibe'],
          preparationNotes: aiResult['preparationNotes'],
        );
      } catch (e) {
        // Fallback or ignore AI error and continue with basic mystery
        print('Mystery AI generation failed: $e');
      }

      // 2. Save to Firestore
      final docRef = await firestore
          .collection(_mysteryCollection)
          .add(mysteryToCreate.toFirestore());

      return mysteryToCreate.copyWith(id: docRef.id);
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
      final doc =
          await firestore.collection(_mysteryCollection).doc(mysteryId).get();

      if (!doc.exists) {
        throw Exception('Mystery not found');
      }

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

  @override
  Future<String?> matchMysteryExperience(MysteryModel mystery) async {
    try {
      // Query experiences collection for active & mystery available experiences
      Query<Map<String, dynamic>> query = firestore
          .collection('experiences')
          .where('isActive', isEqualTo: true)
          .where('isMysteryAvailable', isEqualTo: true);

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) return null;

      // Filter in memory for budget and category to avoid requiring composite indexes initially
      final matches = snapshot.docs.where((doc) {
        final data = doc.data();
        final price = (data['price'] as num?)?.toDouble() ?? 0.0;

        // Filter by budget
        if (price < mystery.budgetMin || price > mystery.budgetMax)
          return false;

        // Filter by category if not 'surpriseMe'
        if (mystery.experienceType.name != 'surpriseMe') {
          final category = data['category'] as String?;
          switch (mystery.experienceType.name) {
            case 'adventure':
              if (category != 'Adventure' && category != 'Nature') return false;
              break;
            case 'foodAndDrink':
              if (category != 'Food & Drink') return false;
              break;
            case 'artsAndCulture':
              if (category != 'Arts & Culture') return false;
              break;
          }
        }
        return true;
      }).toList();

      if (matches.isEmpty) return null;

      // Randomly select one match (in a real app, maybe use random number or weighting)
      matches.shuffle();
      return matches.first.id;
    } on FirebaseException catch (e) {
      throw Exception('Failed to match mystery experience: ${e.message}');
    }
  }
}
