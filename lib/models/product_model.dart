import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e/utils/constants.dart';

class ProductModel {
  final String id;
  final String name;
  final double price;
  final String category;
  final String description;
  final String shopId;
  final String sellerId;
  final String sellerName; // Added sellerName
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.shopId,
    required this.sellerId,
    required this.sellerName, // Added sellerName
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'description': description,
      'shopId': shopId,
      'sellerId': sellerId,
      'sellerName': sellerName, // Added sellerName
      'imageUrl': imageUrl,
    };
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      shopId: map['shopId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? 'Unknown Seller', // Added sellerName
      imageUrl: map['imageUrl'] ?? kDefaultImageUrl,
    );
  }

  factory ProductModel.fromSnapshot(DocumentSnapshot snapshot) {
    return ProductModel.fromMap(
        snapshot.id, snapshot.data() as Map<String, dynamic>);
  }

  bool isValidCategory() {
    return kProductCategories.contains(category);
  }
}
