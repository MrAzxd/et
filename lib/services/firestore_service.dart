import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e/models/request_model.dart';
import 'package:e/models/shop_model.dart';
import 'package:e/utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a shop
  Future<String> createShop({
    required String sellerId,
    required String name,
    required String description,
  }) async {
    try {
      final docRef = await _firestore.collection(kShopsCollection).add({
        'name': name,
        'description': description,
        'sellerId': sellerId,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create shop: $e');
    }
  }

  // Get shop by ID
  Future<ShopModel?> getShop(String shopId) async {
    try {
      final doc =
          await _firestore.collection(kShopsCollection).doc(shopId).get();
      if (doc.exists) {
        return ShopModel.fromSnapshot(doc); // Fixed typo: removed "Doc()"
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get shop: $e');
    }
  }

  // Create a product
  Future<void> createProduct({
    required String shopId,
    required String name,
    required double price,
    required String category,
    required String description,
    required String imageUrl,
    required String sellerId,
    required String sellerName, // Add sellerId
  }) async {
    try {
      await _firestore.collection(kProductsCollection).add({
        'shopId': shopId,
        'name': name,
        'price': price,
        'category': category,
        'description': description,
        'imageUrl': imageUrl,
        'sellerId': sellerId,
        'sellerName': sellerName,
      });
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  // Update a product
  Future<void> updateProduct({
    required String productId,
    required String shopId,
    required String name,
    required double price,
    required String category,
    required String description,
    required String? imageUrl,
    required String sellerId,
  }) async {
    try {
      final doc =
          await _firestore.collection(kProductsCollection).doc(productId).get();
      if (!doc.exists) {
        throw Exception('Product document does not exist');
      }
      await _firestore.collection(kProductsCollection).doc(productId).update({
        'name': name,
        'price': price,
        'category': category,
        'description': description,
        'shopId': shopId,
        'sellerId': sellerId,
        'imageUrl': imageUrl ?? kDefaultImageUrl,
      });
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete a product
  Future<void> deleteProduct(String productId, String shopId) async {
    try {
      final doc =
          await _firestore.collection(kProductsCollection).doc(productId).get();
      if (!doc.exists) {
        throw Exception('Product document does not exist');
      }
      await _firestore.collection(kProductsCollection).doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Get all products stream
  Stream<QuerySnapshot> getProductsStream() {
    return _firestore.collection(kProductsCollection).snapshots();
  }

  // Get products by shop ID
  Stream<QuerySnapshot> getProductsByShop(String shopId) {
    return _firestore
        .collection(kProductsCollection)
        .where('shopId', isEqualTo: shopId)
        .snapshots();
  }

  // Get products by category
  Stream<QuerySnapshot> getProductsByCategory(String category) {
    return _firestore
        .collection(kProductsCollection)
        .where('category', isEqualTo: category)
        .snapshots();
  }

  // Create a seller request
  Future<void> createSellerRequest(String sellerId) async {
    try {
      await _firestore.collection(kRequestsCollection).add({
        'sellerId': sellerId,
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to create seller request: $e');
    }
  }

  // Get seller request by seller ID
  Future<RequestModel?> getSellerRequest(String sellerId) async {
    try {
      final query = await _firestore
          .collection(kRequestsCollection)
          .where('sellerId', isEqualTo: sellerId)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return RequestModel.fromSnapshot(query.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get seller request: $e');
    }
  }

  // Get pending requests stream
  Stream<QuerySnapshot> getPendingRequests() {
    return _firestore
        .collection(kRequestsCollection)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // Get all requests stream
  Stream<QuerySnapshot> getAllRequests() {
    return _firestore
        .collection(kRequestsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update request status
  Future<void> updateRequestStatus(String requestId, String status, {String? rejectionReason}) async {
    if (!['pending', 'approved', 'rejected'].contains(status)) {
      throw Exception('Invalid status');
    }
    try {
      final Map<String, dynamic> updates = {'status': status};
      if (status == 'pending') {
        // Clear rejection reason when resubmitting
        updates['rejectionReason'] = null;
      } else if (rejectionReason != null && rejectionReason.isNotEmpty) {
        updates['rejectionReason'] = rejectionReason;
      }
      await _firestore.collection(kRequestsCollection).doc(requestId).update(updates);
    } catch (e) {
      throw Exception('Failed to update request status: $e');
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc =
          await _firestore.collection(kUsersCollection).doc(userId).get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Update user shopId
  Future<void> updateUserShopId(String userId, String shopId) async {
    try {
      await _firestore.collection(kUsersCollection).doc(userId).update({
        'shopId': shopId,
      });
    } catch (e) {
      throw Exception('Failed to update user shop ID: $e');
    }
  }

  Stream<QuerySnapshot> getAllShops() {
    return FirebaseFirestore.instance.collection('shops').snapshots();
  }

  Stream<QuerySnapshot> getProductsBySeller(String sellerId) {
    return FirebaseFirestore.instance
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots();
  }

  Future<Map<String, dynamic>?> getShopData(String shopId) async {
    final doc =
        await FirebaseFirestore.instance.collection('shops').doc(shopId).get();
    return doc.data();
  }
}
