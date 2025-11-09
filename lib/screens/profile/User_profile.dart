import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e/screens/buyer/cart/cart_screen.dart';
import 'package:e/screens/buyer/orders.dart';
import 'package:e/screens/profile/Settings.dart';
import 'package:e/screens/profile/Support_Screen.dart';
import 'package:e/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _userData;
  bool _loading = true;
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final snapshot =
            await _firestore.collection("users").doc(user.uid).get();
        if (snapshot.exists) {
          setState(() {
            _userData = snapshot.data();
            _loading = false;
          });
        } else {
          setState(() {
            _isGuest = true;
            _loading = false;
          });
        }
      } catch (e) {
        setState(() {
          _isGuest = true;
          _loading = false;
        });
      }
    } else {
      setState(() {
        _isGuest = true;
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Profile Header
                UserAccountsDrawerHeader(
                  accountName: Text(
                    _isGuest ? "Guest User" : (_userData?["name"] ?? "No Name"),
                  ),
                  accountEmail: Text(
                    _isGuest
                        ? "guest@freshcart.com"
                        : (_userData?["email"] ?? ""),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: (!_isGuest &&
                            _userData != null &&
                            _userData!["profileImage"] != null)
                        ? NetworkImage(_userData!["profileImage"])
                        : null,
                    child: (_isGuest || _userData?["profileImage"] == null)
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                ),

                // Tiles
                _buildTile(
                  icon: Icons.shopping_cart,
                  title: "My Cart",
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CartScreen(),
                    ),
                  ),
                ),
                _buildTile(
                  icon: Icons.history,
                  title: "Order History",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderHistoryScreen(),
                      ),
                    );
                  },
                ),
                _buildTile(
                  icon: Icons.favorite,
                  title: "Wishlist",
                  onTap: () => _handleTap("/wishlist"),
                ),
                _buildTile(
                    icon: Icons.settings,
                    title: "Settings",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    }),
                _buildTile(
                    icon: Icons.help,
                    title: "Help & Support",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const HelpSupportScreen(),
                        ),
                      );
                    }),

                const Divider(),

                // Login / Logout
                _buildTile(
                  icon: _isGuest ? Icons.login : Icons.logout,
                  title: _isGuest ? "Login" : "Logout",
                  onTap: () {
                    if (_isGuest) {
                      Navigator.pushNamed(context, "/login");
                    } else {
                      _logout();
                    }
                  },
                ),
              ],
            ),
    );
  }

  // --- Helper function for ListTile
  Widget _buildTile(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: kTextColorSecondary),
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  // --- Guest Restriction Handler
  void _handleTap(String route) {
    if (_isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to access this feature")),
      );
    } else {
      Navigator.pushNamed(context, route);
    }
  }
}
