import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:e/utils/constants.dart';

class SellerSettingsScreen extends StatefulWidget {
  static const routeName = "/seller-settings";

  const SellerSettingsScreen({super.key});

  @override
  State<SellerSettingsScreen> createState() => _SellerSettingsScreenState();
}

class _SellerSettingsScreenState extends State<SellerSettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool loading = true;

  Map<String, dynamic>? seller;

  @override
  void initState() {
    super.initState();
    loadSellerSettings();
  }

  Future<void> loadSellerSettings() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot =
        await _firestore.collection("sellers").doc(user.uid).get();

    if (snapshot.exists) {
      seller = snapshot.data();

      shopNameController.text = seller?["shopName"] ?? "";
      phoneController.text = seller?["phone"] ?? "";
      addressController.text = seller?["address"] ?? "";
    }

    setState(() => loading = false);
  }

  Future<void> saveSettings() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection("sellers").doc(user.uid).update({
      "shopName": shopNameController.text.trim(),
      "phone": phoneController.text.trim(),
      "address": addressController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Settings Updated Successfully!"),
        backgroundColor: kPrimaryColor,
      ),
    );

    Navigator.pop(context); // Back to profile
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text("Seller Settings", style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // FORM FIELDS
                  TextField(
                    controller: shopNameController,
                    decoration: const InputDecoration(
                      labelText: "Shop Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: "Shop Address",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: saveSettings,
                      child: const Text(
                        "Save Settings",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
