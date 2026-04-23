import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItemModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String category;
  int stock;
  final double avgRating;
  final int ratingCount;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.stock,
    this.avgRating = 0,
    this.ratingCount = 0,
  });

  factory MenuItemModel.fromMap(String id, Map<String, dynamic> map) {
    return MenuItemModel(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      stock: map['stock'] ?? 0,
      avgRating: (map['avgRating'] ?? 0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'price': price,
    'description': description,
    'imageUrl': imageUrl,
    'category': category,
    'stock': stock,
    'avgRating': avgRating,
    'ratingCount': ratingCount,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
