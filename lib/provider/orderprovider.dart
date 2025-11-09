import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class OrdersProvider with ChangeNotifier {
  Map<String, int> _statusCounts = {
    'Pending': 0,
    'Processing': 0,
    'Shipped': 0,
    'Delivered': 0,
    'Cancelled': 0,
    'Returned': 0,
  };

  Map<String, int> get statusCounts => _statusCounts;

  String? _sellerId;

  OrdersProvider() {
    _initSellerAndListen();
  }

  Future<void> _initSellerAndListen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data()!.containsKey('sellerId')) {
        _sellerId = doc.get('sellerId') as String;
        _listenToShopOrders();
      }
    } catch (e) {
      debugPrint('Error fetching sellerId: $e');
    }
  }

  void _listenToShopOrders() {
    if (_sellerId == null) return;

    FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: _sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _statusCounts = {
        'Pending': 0,
        'Processing': 0,
        'Shipped': 0,
        'Delivered': 0,
        'Cancelled': 0,
        'Returned': 0,
      };

      for (var doc in snapshot.docs) {
        final status = doc['status']?.toString() ?? 'Unknown';
        if (_statusCounts.containsKey(status)) {
          _statusCounts[status] = (_statusCounts[status]! + 1);
        }
      }

      notifyListeners();
    }, onError: (error) {
      debugPrint('Error fetching shop orders: $error');
      notifyListeners();
    });
  }
}
