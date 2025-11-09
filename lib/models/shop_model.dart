import 'package:cloud_firestore/cloud_firestore.dart';

class ShopModel {
  final String id;
  final String name;
  final String description;
  final String sellerId;

  ShopModel({
    required this.id,
    required this.name,
    required this.description,
    required this.sellerId,
  });

  // Convert ShopModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'sellerId': sellerId,
    };
  }

  // Create ShopModel from Firestore document
  factory ShopModel.fromMap(String id, Map<String, dynamic> map) {
    return ShopModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      sellerId: map['sellerId'] ?? '',
    );
  }

  // Create ShopModel from Firestore snapshot
  factory ShopModel.fromSnapshot(DocumentSnapshot snapshot) {
    return ShopModel.fromMap(
        snapshot.id, snapshot.data() as Map<String, dynamic>);
  }
}
