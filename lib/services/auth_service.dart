import 'package:e/models/Seller_model.dart';
import 'package:e/models/user_model.dart';
import 'package:e/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception('Sign-in failed: $e');
    }
  }

  // Sign up with email, password, name, and role
  Future<User?> signUp(String email, String password, String name, String role) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        final userModel = UserModel(
          id: user.uid,
          email: email,
          role: role,
          name: name,
        );
        await _firestore
            .collection(kUsersCollection)
            .doc(user.uid)
            .set(userModel.toMap());
      }
      return user;
    } catch (e) {
      throw Exception('Sign-up failed: $e');
    }
  }

  

  // Future<User?> sigUpAsSeller(
  //     String email,
  //     String password,
  //     String name,
  //     String city,
  //     String shopCategory,
  //     String cnic,
  //     String shopDes,
  //     // ignore: non_constant_identifier_names
  //     String ShopName,
  //     {String? shopAddress}) async {
  //   try {
  //     final UserCredential userCredential =
  //         await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     final user = userCredential.user;
  //     if (user != null) {
  //       final sellerModel = SellerModel(
  //         id: user.uid,
  //         email: email,
  //         role: 'seller', // Role will be set in RoleSelectionScreen
  //         name: name,
  //         city: city,
  //         cnic: cnic,
  //         shopAddress: shopAddress,
  //         shopCategory: shopCategory,
  //         shopDescription: shopDes,
  //         shopName: ShopName,
  //       );
  //       await _firestore
  //           .collection(kUsersCollection)
  //           .doc(user.uid)
  //           .set(sellerModel.toMap());
  //     }
  //     return user;
  //   } catch (e) {
  //     throw Exception('Sign-up failed: $e');
  //   }
  // }

  // Update user role
  Future<void> updateUserRole(String userId, String role) async {
    try {
      if (!['buyer', 'seller'].contains(role)) {
        throw Exception('Invalid role');
      }
      await _firestore.collection(kUsersCollection).doc(userId).update({
        'role': role,
      });
    } catch (e) {
      throw Exception('Failed to update role: $e');
    }
  }

  // Update user shop details
  Future<void> updateUserShopDetails(String userId, {
    String? shopName,
    String? city,
    String? shopAddress,
    String? shopCategory,
    String? cnic,
    String? shopDescription,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (shopName != null) updates['shopName'] = shopName;
      if (city != null) updates['city'] = city;
      if (shopAddress != null) updates['shopAddress'] = shopAddress;
      if (shopCategory != null) updates['shopCategory'] = shopCategory;
      if (cnic != null) updates['cnic'] = cnic;
      if (shopDescription != null) updates['shopDescription'] = shopDescription;
      
      await _firestore.collection(kUsersCollection).doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update shop details: $e');
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
}
