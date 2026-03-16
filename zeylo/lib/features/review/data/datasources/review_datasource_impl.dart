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

  @override
  Stream<List<ReviewModel>> getReviewsStream(String experienceId) {
    return _firestore
        .collection('reviews')
        .where('experienceId', isEqualTo: experienceId)
        .where('role', isEqualTo: 'seeker')
        .snapshots()
        .map((snapshot) {
      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc.data(), doc.id))
          .toList();
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    });
  }

  @override
  Future<void> toggleHelpful(String reviewId, String userId) async {
    final reviewRef = _firestore.collection('reviews').doc(reviewId);
    final doc = await reviewRef.get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final helpfulUserIds = List<String>.from(data['helpfulUserIds'] ?? []);

    if (helpfulUserIds.contains(userId)) {
      await reviewRef.update({
        'helpfulUserIds': FieldValue.arrayRemove([userId])
      });
    } else {
      await reviewRef.update({
        'helpfulUserIds': FieldValue.arrayUnion([userId])
      });
    }
  }

  @override
  Future<void> reportReview(
      String reviewId, String reporterId, String hostId) async {
    final batch = _firestore.batch();

    // 1. Mark review as reported
    final reviewRef = _firestore.collection('reviews').doc(reviewId);
    batch.update(reviewRef, {'isReported': true});

    // 2. Create activity/notification for host
    final activityRef = _firestore.collection('activities').doc();
    batch.set(activityRef, {
      'userId': hostId,
      'title': 'Review Reported 🚩',
      'message': 'A guest has reported a review on your experience. Tap to take action.',
      'createdAt': FieldValue.serverTimestamp(),
      'type': 'review_report',
      'isRead': false,
      'reviewId': reviewId,
    });

    await batch.commit();
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    final reviewRef = _firestore.collection('reviews').doc(reviewId);
    final reviewDoc = await reviewRef.get();
    
    if (!reviewDoc.exists) return;
    
    final reviewData = reviewDoc.data()!;
    final double rating = (reviewData['rating'] as num?)?.toDouble() ?? 0.0;
    final String experienceId = reviewData['experienceId'] ?? '';
    final String hostId = reviewData['revieweeId'] ?? '';
    final String role = reviewData['role'] ?? '';

    final batch = _firestore.batch();

    // 1. Update Experience stats if it was a seeker review
    if (role == 'seeker' && experienceId.isNotEmpty) {
      final expRef = _firestore.collection('experiences').doc(experienceId);
      final expDoc = await expRef.get();
      
      if (expDoc.exists) {
        final data = expDoc.data()!;
        final currentRating = (data['averageRating'] as num?)?.toDouble() ?? 0.0;
        final currentCount = (data['reviewCount'] as num?)?.toInt() ?? 0;
        
        if (currentCount > 1) {
          final newCount = currentCount - 1;
          final newRating = ((currentRating * currentCount) - rating) / newCount;
          batch.update(expRef, {
            'averageRating': newRating,
            'reviewCount': newCount,
          });
        } else {
          batch.update(expRef, {
            'averageRating': 0.0,
            'reviewCount': 0,
          });
        }
      }

      // 2. Update Host User stats
      if (hostId.isNotEmpty) {
        final userRef = _firestore.collection('users').doc(hostId);
        final userDoc = await userRef.get();
        if (userDoc.exists) {
          final data = userDoc.data()!;
          final userStats = data['stats'] as Map<String, dynamic>? ?? {};
          final currentAvg = (userStats['averageRating'] as num?)?.toDouble() ?? 0.0;
          final currentTotalCount = (userStats['totalReviews'] as num?)?.toInt() ?? 0;
          
          if (currentTotalCount > 1) {
            final newTotalCount = currentTotalCount - 1;
            final newAvg = ((currentAvg * currentTotalCount) - rating) / newTotalCount;
            batch.update(userRef, {
              'stats.averageRating': newAvg,
              'stats.totalReviews': newTotalCount,
            });
          } else {
            batch.update(userRef, {
              'stats.averageRating': 0.0,
              'stats.totalReviews': 0,
            });
          }
        }
      }
    }

    // 3. Delete the review doc
    batch.delete(reviewRef);

    await batch.commit();
  }
}
