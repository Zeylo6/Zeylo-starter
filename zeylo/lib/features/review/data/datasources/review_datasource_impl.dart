import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import 'review_datasource.dart';

class ReviewDatasourceImpl implements ReviewDatasource {
  final FirebaseFirestore _firestore;

  ReviewDatasourceImpl(this._firestore);

  @override
  Future<void> submitReview(ReviewModel review) async {
    final batch = _firestore.batch();
    
    // 1. Create the new review document
    final reviewRef = _firestore.collection('reviews').doc();
    final newReview = ReviewModel(
      id: reviewRef.id,
      bookingId: review.bookingId,
      experienceId: review.experienceId,
      reviewerId: review.reviewerId,
      revieweeId: review.revieweeId,
      role: review.role,
      rating: review.rating,
      message: review.message,
      createdAt: review.createdAt,
    );
    batch.set(reviewRef, newReview.toFirestore());

    // 2. Update the booking to mark it as rated
    final bookingRef = _firestore.collection('bookings').doc(review.bookingId);
    if (review.role == 'seeker') {
      batch.update(bookingRef, {'isRatedBySeeker': true});
    } else {
      batch.update(bookingRef, {'isRatedByHost': true});
    }

    // 3. Update related stats depending on the role
    if (review.role == 'seeker') {
      // Seeker rating host: Update Experience stats
      final expRef = _firestore.collection('experiences').doc(review.experienceId);
      final expDoc = await expRef.get();
      
      if (expDoc.exists) {
        final data = expDoc.data()!;
        final currentRating = (data['averageRating'] as num?)?.toDouble() ?? 0.0;
        final currentCount = (data['reviewCount'] as num?)?.toInt() ?? 0;
        
        final newCount = currentCount + 1;
        final newRating = ((currentRating * currentCount) + review.rating) / newCount;
        
        batch.update(expRef, {
          'averageRating': newRating,
          'reviewCount': newCount,
        });
      }

      // Seeker rating host: Update Host User stats
      final userRef = _firestore.collection('users').doc(review.revieweeId);
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        final userStats = data['stats'] as Map<String, dynamic>? ?? {};
        final currentAvg = (userStats['averageRating'] as num?)?.toDouble() ?? 0.0;
        final currentTotalCount = (userStats['totalReviews'] as num?)?.toInt() ?? 0;
        
        final newTotalCount = currentTotalCount + 1;
        final newAvg = ((currentAvg * currentTotalCount) + review.rating) / newTotalCount;
        
        batch.update(userRef, {
          'stats.averageRating': newAvg,
          'stats.totalReviews': newTotalCount,
        });
      }
    } else if (review.role == 'host') {
      // Host rating seeker: Update Seeker User stats
      final userRef = _firestore.collection('users').doc(review.revieweeId);
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        final userStats = data['stats'] as Map<String, dynamic>? ?? {};
        final currentAvg = (userStats['averageRating'] as num?)?.toDouble() ?? 0.0;
        final currentTotalCount = (userStats['totalReviews'] as num?)?.toInt() ?? 0;
        
        final newTotalCount = currentTotalCount + 1;
        final newAvg = ((currentAvg * currentTotalCount) + review.rating) / newTotalCount;
        
        batch.update(userRef, {
          'stats.averageRating': newAvg,
          'stats.totalReviews': newTotalCount,
        });
      }
    }

    await batch.commit();
  }

  @override
  Future<List<ReviewModel>> getReviewsForExperience(String experienceId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('experienceId', isEqualTo: experienceId)
          .where('role', isEqualTo: 'seeker')
          .get();

      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc.data(), doc.id))
          .toList();
      
      // Sort in memory to avoid mandatory composite index
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return reviews;
    } catch (e) {
      print('Error fetching reviews: $e');
      rethrow;
    }
  }
}
