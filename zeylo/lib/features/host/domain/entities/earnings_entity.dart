import 'package:equatable/equatable.dart';

/// Earnings entity for domain layer
class EarningsEntity extends Equatable {
  final String hostId;
  final double totalBalance;
  final double grossIncome;
  final double platformFee;
  final List<PayoutEntity> payouts;
  final DateTime updatedAt;

  const EarningsEntity({
    required this.hostId,
    required this.totalBalance,
    required this.grossIncome,
    required this.platformFee,
    required this.payouts,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        hostId,
        totalBalance,
        grossIncome,
        platformFee,
        payouts,
        updatedAt,
      ];

  EarningsEntity copyWith({
    String? hostId,
    double? totalBalance,
    double? grossIncome,
    double? platformFee,
    List<PayoutEntity>? payouts,
    DateTime? updatedAt,
  }) {
    return EarningsEntity(
      hostId: hostId ?? this.hostId,
      totalBalance: totalBalance ?? this.totalBalance,
      grossIncome: grossIncome ?? this.grossIncome,
      platformFee: platformFee ?? this.platformFee,
      payouts: payouts ?? this.payouts,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Payout entity
class PayoutEntity extends Equatable {
  final String id;
  final double amount;
  final DateTime date;
  final PayoutStatus status;

  const PayoutEntity({
    required this.id,
    required this.amount,
    required this.date,
    this.status = PayoutStatus.completed,
  });

  @override
  List<Object?> get props => [id, amount, date, status];

  PayoutEntity copyWith({
    String? id,
    double? amount,
    DateTime? date,
    PayoutStatus? status,
  }) {
    return PayoutEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}

enum PayoutStatus {
  pending,
  completed,
  failed,
  cancelled,
}
