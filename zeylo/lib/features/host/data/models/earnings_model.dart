import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/earnings_entity.dart';

/// Earnings model for data layer
class EarningsModel extends EarningsEntity {
  const EarningsModel({
    required super.hostId,
    required super.totalBalance,
    required super.grossIncome,
    required super.platformFee,
    required super.payouts,
    required super.updatedAt,
  });

  factory EarningsModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final payoutsData = data['payouts'] as List<dynamic>? ?? [];
    final payouts = payoutsData
        .map((p) => PayoutModel.fromMap(p as Map<String, dynamic>))
        .toList();

    return EarningsModel(
      hostId: doc.id,
      totalBalance: (data['totalBalance'] as num?)?.toDouble() ?? 0.0,
      grossIncome: (data['grossIncome'] as num?)?.toDouble() ?? 0.0,
      platformFee: (data['platformFee'] as num?)?.toDouble() ?? 0.0,
      payouts: payouts,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalBalance': totalBalance,
      'grossIncome': grossIncome,
      'platformFee': platformFee,
      'payouts': payouts
          .map((p) => (p as PayoutModel).toMap())
          .toList(),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  @override
  EarningsModel copyWith({
    String? hostId,
    double? totalBalance,
    double? grossIncome,
    double? platformFee,
    List<PayoutEntity>? payouts,
    DateTime? updatedAt,
  }) {
    return EarningsModel(
      hostId: hostId ?? this.hostId,
      totalBalance: totalBalance ?? this.totalBalance,
      grossIncome: grossIncome ?? this.grossIncome,
      platformFee: platformFee ?? this.platformFee,
      payouts: payouts ?? this.payouts,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Payout model
class PayoutModel extends PayoutEntity {
  const PayoutModel({
    required super.id,
    required super.amount,
    required super.date,
    super.status = PayoutStatus.completed,
  });

  factory PayoutModel.fromMap(Map<String, dynamic> map) {
    return PayoutModel(
      id: map['id'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: _parsePayoutStatus(map['status'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'status': status.toString().split('.').last,
    };
  }

  static PayoutStatus _parsePayoutStatus(String? status) {
    return switch (status) {
      'pending' => PayoutStatus.pending,
      'completed' => PayoutStatus.completed,
      'failed' => PayoutStatus.failed,
      'cancelled' => PayoutStatus.cancelled,
      _ => PayoutStatus.completed,
    };
  }

  @override
  PayoutModel copyWith({
    String? id,
    double? amount,
    DateTime? date,
    PayoutStatus? status,
  }) {
    return PayoutModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}
