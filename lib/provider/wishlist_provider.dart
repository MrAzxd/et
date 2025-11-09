import 'package:e/models/product_model.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistProvider with ChangeNotifier {
  List<ProductModel> _items = [];

  WishlistProvider() {
    _loadWishlist();
  }

  List<ProductModel> get items => _items;

  Future<void> _loadWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('fav_orders')
          .doc(user.email)
          .collection('products')
          .get();
      _items = snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.id, doc.data());
      }).toList();
      notifyListeners();
    }
  }

  Future<void> addItem(ProductModel product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance
          .collection('fav_orders')
          .doc(user.email)
          .collection('products')
          .doc(product.id);
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        await docRef.set(product.toMap());
        _items.add(product);
        notifyListeners();
      }
    }
  }

  Future<void> removeItem(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance
          .collection('fav_orders')
          .doc(user.email)
          .collection('products')
          .doc(productId);
      await docRef.delete();
      _items.removeWhere((item) => item.id == productId);
      notifyListeners();
    }
  }

  Future<void> clearWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('fav_orders')
          .doc(user.email)
          .collection('products')
          .get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      _items.clear();
      notifyListeners();
    }
  }
}
