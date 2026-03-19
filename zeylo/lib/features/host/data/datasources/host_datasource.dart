import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/earnings_model.dart';
import '../models/host_stats_model.dart';

/// Abstract datasource for host operations
abstract class HostDatasource {
  /// Get host statistics
  Future<HostStatsModel> getHostStats(String hostId);

  /// Get host earnings
  Future<EarningsModel> getEarnings(String hostId);

  /// Get this month's earnings
  Future<double> getThisMonthEarnings(String hostId);

  /// Get earnings trend percentage
  Future<double> getEarningsTrend(String hostId);

  /// Watch host statistics reactively
  Stream<HostStatsModel> watchHostStats(String hostId);

  /// Watch this month's earnings reactively
  Stream<double> watchThisMonthEarnings(String hostId);
}

/// Firestore implementation of host datasource
class HostFirestoreDatasource implements HostDatasource {
  final FirebaseFirestore _firestore;

  HostFirestoreDatasource(this._firestore);

  static const String _hostsCollection = 'hosts';
  static const String _earningsCollection = 'earnings';

  @override
  Future<HostStatsModel> getHostStats(String hostId) async {
    // 1. Get the host document (for profile completion, etc.)
    final hostDoc = await _firestore.collection(_hostsCollection).doc(hostId).get();
    int profileCompletion = 0;
    int superHostBadgeStatus = 0;
    
    if (hostDoc.exists) {
      final hostData = hostDoc.data()!;
      profileCompletion = hostData['profileCompletion'] as int? ?? 0;
      superHostBadgeStatus = hostData['superHostBadgeStatus'] as int? ?? 0;
    }

    // 2. Get the User document for the aggregated rating stats (updated by reviews)
    final userDoc = await _firestore.collection('users').doc(hostId).get();
    double averageRating = 0.0;
    int totalBookings = 0; // Or total reviews
    
    if (userDoc.exists) {
      final userData = userDoc.data()!;
      final statsMap = userData['stats'] as Map<String, dynamic>? ?? {};
      averageRating = (statsMap['averageRating'] as num?)?.toDouble() ?? 0.0;
      totalBookings = (statsMap['totalReviews'] as num?)?.toInt() ?? 0;
    }

    return HostStatsModel(
      hostId: hostId,
      earnings: 0.0, // Used to be stored in document, usually handled by earnings collection
      averageRating: averageRating,
      responseRate: 100.0, // Defaulting for now
      acceptanceRate: 100.0, // Defaulting for now
      totalBookings: totalBookings, // Showing reviews count as "bookings" stat temporarily
      profileCompletion: profileCompletion,
      superHostBadgeStatus: superHostBadgeStatus,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<EarningsModel> getEarnings(String hostId) async {
    final doc = await _firestore
        .collection(_hostsCollection)
        .doc(hostId)
        .collection(_earningsCollection)
        .doc('current')
        .get();

    if (!doc.exists) {
      // Return empty earnings model
      return EarningsModel(
        hostId: hostId,
        totalBalance: 0,
        grossIncome: 0,
        platformFee: 0,
        payouts: [],
        updatedAt: DateTime.now(),
      );
    }

    return EarningsModel.fromFirestore(
      doc,
    );
  }

  @override
  Future<double> getThisMonthEarnings(String hostId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final snapshot = await _firestore
          .collection(_hostsCollection)
          .doc(hostId)
          .collection(_earningsCollection)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      double total = 0;
      for (final doc in snapshot.docs) {
        total += (doc['amount'] as num?)?.toDouble() ?? 0;
      }

      return total;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<double> getEarningsTrend(String hostId) async {
    try {
      final now = DateTime.now();
      final currentMonthStart = DateTime(now.year, now.month, 1);
      final currentMonthEnd = DateTime(now.year, now.month + 1, 0);
      final previousMonthStart = DateTime(now.year, now.month - 1, 1);
      final previousMonthEnd = DateTime(now.year, now.month, 0);

      // Get current month earnings
      final currentSnapshot = await _firestore
          .collection(_hostsCollection)
          .doc(hostId)
          .collection(_earningsCollection)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(currentMonthStart))
          .where('date',
              isLessThanOrEqualTo: Timestamp.fromDate(currentMonthEnd))
          .get();

      double currentTotal = 0;
      for (final doc in currentSnapshot.docs) {
        currentTotal += (doc['amount'] as num?)?.toDouble() ?? 0;
      }

      // Get previous month earnings
      final previousSnapshot = await _firestore
          .collection(_hostsCollection)
          .doc(hostId)
          .collection(_earningsCollection)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(previousMonthStart))
          .where('date',
              isLessThanOrEqualTo: Timestamp.fromDate(previousMonthEnd))
          .get();

      double previousTotal = 0;
      for (final doc in previousSnapshot.docs) {
        previousTotal += (doc['amount'] as num?)?.toDouble() ?? 0;
      }

      if (previousTotal == 0) return 0;

      return ((currentTotal - previousTotal) / previousTotal) * 100;
    } catch (e) {
      return 0;
    }
  }

  @override
  Stream<HostStatsModel> watchHostStats(String hostId) {
    return _firestore.collection('users').doc(hostId).snapshots().asyncMap((userDoc) async {
      int profileCompletion = 0;
      int superHostBadgeStatus = 0;

      // Fetch host doc once per user update
      final hostDoc = await _firestore.collection(_hostsCollection).doc(hostId).get();
      if (hostDoc.exists) {
        final hostData = hostDoc.data()!;
        profileCompletion = hostData['profileCompletion'] as int? ?? 0;
        superHostBadgeStatus = hostData['superHostBadgeStatus'] as int? ?? 0;
      }

      double averageRating = 0.0;
      int totalBookings = 0;
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final statsMap = userData['stats'] as Map<String, dynamic>? ?? {};
        averageRating = (statsMap['averageRating'] as num?)?.toDouble() ?? 0.0;
        totalBookings = (statsMap['totalReviews'] as num?)?.toInt() ?? 0;
      }

      return HostStatsModel(
        hostId: hostId,
        earnings: 0.0,
        averageRating: averageRating,
        responseRate: 100.0,
        acceptanceRate: 100.0,
        totalBookings: totalBookings,
        profileCompletion: profileCompletion,
        superHostBadgeStatus: superHostBadgeStatus,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });
  }

  @override
  Stream<double> watchThisMonthEarnings(String hostId) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return _firestore
        .collection(_hostsCollection)
        .doc(hostId)
        .collection(_earningsCollection)
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .snapshots()
        .map((snapshot) {
      double total = 0;
      for (final doc in snapshot.docs) {
        total += (doc.data()['amount'] as num?)?.toDouble() ?? 0;
      }
      return total;
    });
  }
}
