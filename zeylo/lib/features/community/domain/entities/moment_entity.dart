import 'package:equatable/equatable.dart';

class Moment extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? experienceId;

  const Moment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.imageUrl,
    required this.createdAt,
    required this.expiresAt,
    this.experienceId,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userAvatar,
        imageUrl,
        createdAt,
        expiresAt,
        experienceId,
      ];
}
