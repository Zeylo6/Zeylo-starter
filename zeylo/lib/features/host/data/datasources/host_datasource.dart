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
}

/// Firestore implementation of host datasource
class HostFirestoreDatasource implements HostDatasource {
  final FirebaseFirestore _firestore;

  HostFirestoreDatasource(this._firestore);

  static const String _hostsCollection = 'hosts';
  static const String _earningsCollection = 'earnings';

  @override
  Future<HostStatsModel> getHostStats(String hostId) async {
    final doc = await _firestore
        .collection(_hostsCollection)
        .doc(hostId)
        .get();

    if (!doc.exists) {
      throw Exception('Host not found');
    }

    return HostStatsModel.fromFirestore(
      doc as DocumentSnapshot<Map<String, dynamic>>,
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
      doc as DocumentSnapshot<Map<String, dynamic>>,
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
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
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
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(currentMonthStart))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(currentMonthEnd))
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
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(previousMonthStart))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(previousMonthEnd))
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
}
