import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/category_entity.dart';

/// Model for Category data
class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String imageUrl;
  final int order;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.imageUrl,
    required this.order,
    required this.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      imageUrl: json['imageUrl'] as String,
      order: json['order'] as int,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] as String,
      icon: data['icon'] as String,
      imageUrl: data['imageUrl'] as String,
      order: data['order'] as int,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'imageUrl': imageUrl,
      'order': order,
      'isActive': isActive,
    };
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      icon: icon,
      imageUrl: imageUrl,
      order: order,
      isActive: isActive,
    );
  }
}
