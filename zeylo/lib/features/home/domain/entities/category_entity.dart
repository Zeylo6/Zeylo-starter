import 'package:equatable/equatable.dart';

/// Entity representing an experience category
class Category extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String imageUrl;
  final int order;
  final bool isActive;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.imageUrl,
    required this.order,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, icon, imageUrl, order, isActive];
}
