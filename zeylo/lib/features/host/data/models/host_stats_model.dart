import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/host_stats_entity.dart';

/// Host stats model for data layer
class HostStatsModel extends HostStatsEntity {
  const HostStatsModel({
    required super.hostId,
    required super.earnings,
    required super.averageRating,
    required super.responseRate,
    required super.acceptanceRate,
    required super.totalBookings,
    required super.profileCompletion,
    super.superHostBadgeStatus = 0,
    required super.createdAt,
    required super.updatedAt,
  });

  factory HostStatsModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return HostStatsModel(
      hostId: doc.id,
      earnings: (data['earnings'] as num?)?.toDouble() ?? 0.0,
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      responseRate: (data['responseRate'] as num?)?.toDouble() ?? 0.0,
      acceptanceRate: (data['acceptanceRate'] as num?)?.toDouble() ?? 0.0,
      totalBookings: data['totalBookings'] as int? ?? 0,
      profileCompletion: data['profileCompletion'] as int? ?? 0,
      superHostBadgeStatus: data['superHostBadgeStatus'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'earnings': earnings,
      'averageRating': averageRating,
      'responseRate': responseRate,
      'acceptanceRate': acceptanceRate,
      'totalBookings': totalBookings,
      'profileCompletion': profileCompletion,
      'superHostBadgeStatus': superHostBadgeStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  HostStatsModel copyWith({
    String? hostId,
    double? earnings,
    double? averageRating,
    double? responseRate,
    double? acceptanceRate,
    int? totalBookings,
    int? profileCompletion,
    int? superHostBadgeStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HostStatsModel(
      hostId: hostId ?? this.hostId,
      earnings: earnings ?? this.earnings,
      averageRating: averageRating ?? this.averageRating,
      responseRate: responseRate ?? this.responseRate,
      acceptanceRate: acceptanceRate ?? this.acceptanceRate,
      totalBookings: totalBookings ?? this.totalBookings,
      profileCompletion: profileCompletion ?? this.profileCompletion,
      superHostBadgeStatus: superHostBadgeStatus ?? this.superHostBadgeStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
