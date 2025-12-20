// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e/screens/auth/login_screen.dart';
import 'package:e/screens/seller/Sellerprofile/Dasbord.dart';
import 'package:e/screens/seller/Sellerprofile/Setting.dart';
import 'package:e/screens/seller/orders.dart';
import 'package:e/screens/seller/product_upload_screen.dart';
import 'package:e/screens/seller/product_edit_screen.dart';

import 'package:e/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class SellerProfileScreen extends StatefulWidget {
  static const routeName = "/seller-profile";

  const SellerProfileScreen({super.key});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? seller;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadSeller();
  }

  Future<void> loadSeller() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot =
          await _firestore.collection("sellers").doc(user.uid).get();

      if (snapshot.exists) {
        setState(() {
          seller = snapshot.data();
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: const Text(
          "Seller Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : AnimationLimiter(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 400),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 40,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    // ----------------- Profile Card -----------------
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(kDefaultBorderRadius * 1.2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundImage: seller?["profileImage"] != null
                                  ? NetworkImage(seller!["profileImage"])
                                  : null,
                              child: seller?["profileImage"] == null
                                  ? const Icon(Icons.store, size: 45)
                                  : null,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              seller?["shopName"] ?? "Shop Name",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              seller?["email"] ?? "",
                              style: const TextStyle(
                                  color: kTextColorSecondary, fontSize: 15),
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ),
                    // sellerDashboard(), // <-- ADD THIS HERE
                    SizedBox(height: 20),
                    // const SizedBox(height: 16),

                    // ----------------- Stats Row -----------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        statBox("Products", seller?["totalProducts"] ?? 0),
                        statBox("Orders", seller?["totalOrders"] ?? 0),
                        statBox("Earnings", "${seller?["earnings"] ?? 0} PKR"),
                      ],
                    ),

                    const SizedBox(height: 25),

                    title("Seller Tools"),

                    menuTile(
                      icon: Icons.add_box_outlined,
                      title: "Add New Product",
                      onTap: () => Navigator.pushNamed(
                          context, ProductUploadScreen.routeName),
                    ),

                    menuTile(
                      icon: Icons.list_alt_rounded,
                      title: "Manage Products",
                      onTap: () => Navigator.pushNamed(
                          context, ProductEditScreen.routeName),
                    ),

                    menuTile(
                      icon: Icons.shopping_bag,
                      title: "Orders Received",
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => OrdersScreen())),
                    ),

                    menuTile(
                      icon: Icons.attach_money_rounded,
                      title: "Earnings Report",
                      onTap: () {},
                    ),

                    const SizedBox(height: 16),
                    title("General"),

                    menuTile(
                        icon: Icons.settings,
                        title: "Settings",
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SellerSettingsScreen()));
                        }),

                    menuTile(
                      icon: Icons.support_agent,
                      title: "Help & Support",
                      onTap: () {},
                    ),

                    Divider(
                      color: kTextColorSecondary.withOpacity(0.3),
                      height: 30,
                    ),

                    menuTile(
                      icon: Icons.logout,
                      title: "Logout",
                      onTap: logout,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ---------------------- Widgets ----------------------

  Widget statBox(String title, dynamic value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: kTextColorSecondary)),
          ],
        ),
      ),
    );
  }

  Widget menuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = kPrimaryColor,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius)),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, size: 28, color: color),
        title: Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }

  Widget title(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor),
      ),
    );
  }
}

// class SellerProfileScreen extends StatefulWidget {
//   const SellerProfileScreen({super.key});

//   @override
//   State<SellerProfileScreen> createState() => _SellerProfileScreenState();
// }

// class _SellerProfileScreenState extends State<SellerProfileScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Map<String, dynamic>? sellerData;
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     loadSellerData();
//   }

//   Future<void> loadSellerData() async {
//     final user = _auth.currentUser;

//     if (user == null) return;

//     final sellerSnap = await _firestore.collection("sellers").doc(user.uid).get();

//     if (sellerSnap.exists) {
//       setState(() {
//         sellerData = sellerSnap.data();
//         loading = false;
//       });
//     } else {
//       setState(() => loading = false);
//     }
//   }

//   Future<void> logout() async {
//     await _auth.signOut();
//     Navigator.pushReplacementNamed(context, "/login");
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // ---------- HEADER ----------
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: const [
//                 BoxShadow(color: Colors.black12, blurRadius: 6),
//               ],
//             ),
//             child: Column(
//               children: [
//                 CircleAvatar(
//                   radius: 40,
//                   backgroundImage: sellerData?["profileImage"] != null
//                       ? NetworkImage(sellerData!["profileImage"])
//                       : null,
//                   child: sellerData?["profileImage"] == null
//                       ? const Icon(Icons.person, size: 50)
//                       : null,
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   sellerData?["shopName"] ?? "Your Shop",
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   sellerData?["email"] ?? "",
//                   style: TextStyle(color: Colors.grey[700]),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 20),

//           // ---------- STATS ----------
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildStatBox("Products", sellerData?["totalProducts"] ?? 0),
//               _buildStatBox("Orders", sellerData?["totalOrders"] ?? 0),
//               _buildStatBox("Earnings", "${sellerData?["earnings"] ?? 0} PKR"),
//             ],
//           ),

//           const SizedBox(height: 20),

//           // ---------- ACTION BUTTONS ----------
//           _sectionTitle("Seller Functions"),

//           _tile(
//             icon: Icons.add_box_outlined,
//             title: "Add New Product",
//             onTap: () => Navigator.pushNamed(context, "/addProduct"),
//           ),
//           _tile(
//             icon: Icons.list_alt_outlined,
//             title: "Manage Products",
//             onTap: () => Navigator.pushNamed(context, "/myProducts"),
//           ),
//           _tile(
//             icon: Icons.shopping_bag,
//             title: "Orders Received",
//             onTap: () => Navigator.pushNamed(context, "/sellerOrders"),
//           ),
//           _tile(
//             icon: Icons.monetization_on_outlined,
//             title: "Earnings Report",
//             onTap: () => Navigator.pushNamed(context, "/earningReport"),
//           ),

//           const SizedBox(height: 10),
//           _sectionTitle("General Options"),

//           _tile(
//             icon: Icons.settings,
//             title: "Settings",
//             onTap: () => Navigator.pushNamed(context, "/settings"),
//           ),
//           _tile(
//             icon: Icons.help_outline,
//             title: "Help & Support",
//             onTap: () => Navigator.pushNamed(context, "/support"),
//           ),

//           const Divider(),
//           _tile(
//             icon: Icons.logout,
//             title: "Logout",
//             onTap: logout,
//           ),
//         ],
//       ),
//     );
//   }

//   // ----------------- WIDGETS -----------------

//   Widget _buildStatBox(String title, dynamic value) {
//     return Expanded(
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
//         ),
//         child: Column(
//           children: [
//             Text("$value",
//                 style: const TextStyle(
//                     fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 4),
//             Text(title, style: TextStyle(color: Colors.grey[600])),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _tile({required IconData icon, required String title, required VoidCallback onTap}) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: ListTile(
//         leading: Icon(icon, color: Colors.green, size: 28),
//         title: Text(title, style: const TextStyle(fontSize: 16)),
//         trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//         onTap: onTap,
//       ),
//     );
//   }

//   Widget _sectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10, left: 4),
//       child: Text(title,
//           style: const TextStyle(
//               fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
//     );
//   }
// }
