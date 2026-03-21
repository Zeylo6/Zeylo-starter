import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/ai_service.dart';
import '../models/chain_model.dart';
import '../../domain/entities/chain_entity.dart';

abstract class ChainDataSource {
  Future<ChainModel> createChain(ChainModel chain);
  Future<List<ChainModel>> getChainsByUserId(String userId);
  Future<ChainModel> getChainById(String chainId);
  Future<ChainModel> updateChain(ChainModel chain);
  Future<void> deleteChain(String chainId);

  Future<List<ChainModel>> getSuggestedChains(
    String destinationCity,
    List<String> interests,
  );

  Future<String> enhancePrompt(String prompt);

  Future<List<ChainExperience>> generateChainExperiences({
    required String prompt,
    required String location,
    required String date,
    required String totalTime,
    required List<String> interests,
  });
}

class ChainDataSourceImpl implements ChainDataSource {
  final FirebaseFirestore firestore;
  final AIService aiService;

  static const String _chainCollection = 'chains';

  ChainDataSourceImpl({
    required this.firestore,
    required this.aiService,
  });

  @override
  Future<ChainModel> createChain(ChainModel chain) async {
    try {
      final docRef =
          await firestore.collection(_chainCollection).add(chain.toFirestore());

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
      final doc =
          await firestore.collection(_chainCollection).doc(chainId).get();

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
      await firestore.collection(_chainCollection).doc(chainId).delete();
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
      final query = firestore
          .collection(_chainCollection)
          .where('destinationCity', isEqualTo: destinationCity)
          .where('status', isEqualTo: 'active');

      final querySnapshot =
          await query.orderBy('createdAt', descending: true).limit(10).get();

      return querySnapshot.docs
          .map((doc) => ChainModel.fromFirestore(doc))
          .where((chain) {
        final chainInterests = chain.interests.map((i) => i.toLowerCase());
        final searchInterests = interests.map((i) => i.toLowerCase());
        return chainInterests.any(
          (interest) => searchInterests.contains(interest),
        );
      }).toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to get suggested chains: ${e.message}');
    }
  }

  @override
  Future<String> enhancePrompt(String prompt) async {
    try {
      return await aiService.enhancePrompt(prompt);
    } catch (e) {
      throw Exception('Failed to enhance prompt: $e');
    }
  }

  @override
  Future<List<ChainExperience>> generateChainExperiences({
    required String prompt,
    required String location,
    required String date,
    required String totalTime,
    required List<String> interests,
  }) async {
    try {
      return await aiService.generateChainExperiences(
        prompt: prompt,
        location: location,
        date: date,
        totalTime: totalTime,
        interests: interests,
      );
    } catch (e) {
      throw Exception('Failed to generate chain experiences: $e');
    }
  }
}