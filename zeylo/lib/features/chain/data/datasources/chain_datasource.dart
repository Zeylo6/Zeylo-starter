import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chain_model.dart';

/// Abstract data source for chain operations
///
/// Defines the contract for chain data operations
abstract class ChainDataSource {
  /// Create a new chain
  Future<ChainModel> createChain(ChainModel chain);

  /// Get all chains for a user
  Future<List<ChainModel>> getChainsByUserId(String userId);

  /// Get a single chain by ID
  Future<ChainModel> getChainById(String chainId);

  /// Update a chain
  Future<ChainModel> updateChain(ChainModel chain);

  /// Delete a chain
  Future<void> deleteChain(String chainId);

  /// Get suggested chains
  Future<List<ChainModel>> getSuggestedChains(
    String destinationCity,
    List<String> interests,
  );
}

/// Firebase implementation of chain data source
class ChainDataSourceImpl implements ChainDataSource {
  /// Firestore instance
  final FirebaseFirestore firestore;

  /// Collection path for chains
  static const String _chainCollection = 'chains';

  ChainDataSourceImpl({required this.firestore});

  @override
  Future<ChainModel> createChain(ChainModel chain) async {
    try {
      final docRef = await firestore
          .collection(_chainCollection)
          .add(chain.toFirestore());

      return chain.copyWith(id: docRef.id);
    } on FirebaseException catch (e) {
      throw Exception('Failed to create chain: ${e.message}');
    }
  }

  @override
  Future<List<ChainModel>> getChainsByUserId(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection(_chainCollection)
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ChainModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to get chains: ${e.message}');
    }
  }

  @override
  Future<ChainModel> getChainById(String chainId) async {
    try {
      final doc = await firestore
          .collection(_chainCollection)
          .doc(chainId)
          .get();

      if (!doc.exists) {
        throw Exception('Chain not found');
      }

      return ChainModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception('Failed to get chain: ${e.message}');
    }
  }

  @override
  Future<ChainModel> updateChain(ChainModel chain) async {
    try {
      await firestore
          .collection(_chainCollection)
          .doc(chain.id)
          .update(chain.toFirestore());

      return chain;
    } on FirebaseException catch (e) {
      throw Exception('Failed to update chain: ${e.message}');
    }
  }

  @override
  Future<void> deleteChain(String chainId) async {
    try {
      await firestore
          .collection(_chainCollection)
          .doc(chainId)
          .delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete chain: ${e.message}');
    }
  }

  @override
  Future<List<ChainModel>> getSuggestedChains(
    String destinationCity,
    List<String> interests,
  ) async {
    try {
      var query = firestore
          .collection(_chainCollection)
          .where('destinationCity', isEqualTo: destinationCity)
          .where('status', isEqualTo: 'active');

      final querySnapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => ChainModel.fromFirestore(doc))
          .where((chain) {
            // Filter by interests match
            final chainInterests = chain.interests.map((i) => i.toLowerCase());
            final searchInterests = interests.map((i) => i.toLowerCase());
            return chainInterests
                .any((interest) => searchInterests.contains(interest));
          })
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to get suggested chains: ${e.message}');
    }
  }
}
