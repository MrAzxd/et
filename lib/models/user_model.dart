import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String role; // buyer, seller, or admin
  final String? name;
  final String? shopId; // Only for sellers, links to their shop
  final String? shopName;
  final String? city;
  final String? shopAddress;
  final String? shopCategory;
  final String? cnic;
  final String? shopDescription;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.shopId,
    this.shopName,
    this.city,
    this.shopAddress,
    this.shopCategory,
    this.cnic,
    this.shopDescription,
  });

  // Convert UserModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'name': name,
      'shopId': shopId,
      'shopName': shopName,
      'city': city,
      'shopAddress': shopAddress,
      'shopCategory': shopCategory,
      'cnic': cnic,
      'shopDescription': shopDescription,
    };
  }

  // Create UserModel from Firestore document
  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      name: map['name'],
      shopId: map['shopId'],
      shopName: map['shopName'],
      city: map['city'],
      shopAddress: map['shopAddress'],
      shopCategory: map['shopCategory'],
      cnic: map['cnic'],
      shopDescription: map['shopDescription'],
    );
  }

  // Create UserModel from Firestore snapshot
  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    return UserModel.fromMap(
        snapshot.id, snapshot.data() as Map<String, dynamic>);
  }

  // Validate role
  bool isValidRole() {
    return ['buyer', 'seller', 'admin'].contains(role);
  }
}
