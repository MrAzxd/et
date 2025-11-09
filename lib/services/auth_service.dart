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

  // Sign up with email, password, and name
  Future<User?> signUp(String email, String password, String name) async {
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
          role: '', // Role will be set in RoleSelectionScreen
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

  // Update user shopId
  Future<void> updateUserShopId(String userId, String shopId) async {
    try {
      await _firestore.collection(kUsersCollection).doc(userId).update({
        'shopId': shopId,
      });
    } catch (e) {
      throw Exception('Failed to update shop ID: $e');
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
