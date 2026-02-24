import 'package:cloud_firestore/cloud_firestore.dart';
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
}

/// Firebase implementation of mystery data source
class MysteryDataSourceImpl implements MysteryDataSource {
  /// Firestore instance
  final FirebaseFirestore firestore;

  /// Collection path for mysteries
  static const String _mysteryCollection = 'mysteries';

  MysteryDataSourceImpl({required this.firestore});

  @override
  Future<MysteryModel> createMystery(MysteryModel mystery) async {
    try {
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
      await firestore
          .collection(_mysteryCollection)
          .doc(mysteryId)
          .delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete mystery: ${e.message}');
    }
  }
}
