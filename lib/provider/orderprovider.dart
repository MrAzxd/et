import 'dart:async';
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
  StreamSubscription? _authSubscription;
  StreamSubscription? _ordersSubscription;

  OrdersProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _fetchSellerIdAndListen(user.uid);
      } else {
        _clearData();
      }
    });
  }

  Future<void> _fetchSellerIdAndListen(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists && doc.data()!.containsKey('sellerId')) {
        _sellerId = doc.get('sellerId') as String;
        _listenToShopOrders();
      } else {
        // Not a seller or missing ID
        _sellerId = null;
        _clearData();
      }
    } catch (e) {
      debugPrint('Error fetching sellerId: $e');
      _sellerId = null;
    }
  }

  void _listenToShopOrders() {
    _ordersSubscription?.cancel();
    if (_sellerId == null) return;

    _ordersSubscription = FirebaseFirestore.instance
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
      // If error is due to missing index, it will appear in debug console
    });
  }

  void _clearData() {
    _ordersSubscription?.cancel();
    _statusCounts = {
      'Pending': 0,
      'Processing': 0,
      'Shipped': 0,
      'Delivered': 0,
      'Cancelled': 0,
      'Returned': 0,
    };
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
