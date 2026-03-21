import 'package:equatable/equatable.dart';

/// Host statistics entity for domain layer
class HostStatsEntity extends Equatable {
  final String hostId;
  final double earnings;
  final double averageRating;
  final double completionRate;
  final double acceptanceRate;
  final int totalBookings;
  final int profileCompletion;
  final int superHostBadgeStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HostStatsEntity({
    required this.hostId,
    required this.earnings,
    required this.averageRating,
    required this.completionRate,
    required this.acceptanceRate,
    required this.totalBookings,
    required this.profileCompletion,
    this.superHostBadgeStatus = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        hostId,
        earnings,
        averageRating,
        completionRate,
        acceptanceRate,
        totalBookings,
        profileCompletion,
        superHostBadgeStatus,
        createdAt,
        updatedAt,
      ];

  HostStatsEntity copyWith({
    String? hostId,
    double? earnings,
    double? averageRating,
    double? completionRate,
    double? acceptanceRate,
    int? totalBookings,
    int? profileCompletion,
    int? superHostBadgeStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HostStatsEntity(
      hostId: hostId ?? this.hostId,
      earnings: earnings ?? this.earnings,
      averageRating: averageRating ?? this.averageRating,
      completionRate: completionRate ?? this.completionRate,
      acceptanceRate: acceptanceRate ?? this.acceptanceRate,
      totalBookings: totalBookings ?? this.totalBookings,
      profileCompletion: profileCompletion ?? this.profileCompletion,
      superHostBadgeStatus: superHostBadgeStatus ?? this.superHostBadgeStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
