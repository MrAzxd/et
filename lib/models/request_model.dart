import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String id;
  final String sellerId;
  final String status; // pending, approved, rejected
  final Timestamp createdAt;
  final String? rejectionReason;

  RequestModel({
    required this.id,
    required this.sellerId,
    required this.status,
    required this.createdAt,
    this.rejectionReason,
  });

  // Convert RequestModel to Fireellstore document
  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'status': status,
      'createdAt': createdAt,      'rejectionReason': rejectionReason,    };
  }

  // Create RequestModel from Firestore document
  factory RequestModel.fromMap(String id, Map<String, dynamic> map) {
    return RequestModel(
      id: id,
      sellerId: map['sellerId'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      rejectionReason: map['rejectionReason'],
    );
  }

  // Create RequestModel from Firestore snapshot
  factory RequestModel.fromSnapshot(DocumentSnapshot snapshot) {
    return RequestModel.fromMap(
        snapshot.id, snapshot.data() as Map<String, dynamic>);
  }

  // Validate status
  bool isValidStatus() {
    return ['pending', 'approved', 'rejected'].contains(status);
  }
}
