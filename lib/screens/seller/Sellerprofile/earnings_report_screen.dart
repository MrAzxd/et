import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EarningsReportScreen extends StatefulWidget {
  static const String routeName = '/earnings-report';

  const EarningsReportScreen({super.key});

  @override
  State<EarningsReportScreen> createState() => _EarningsReportScreenState();
}

class _EarningsReportScreenState extends State<EarningsReportScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? sellerData;
  List<Map<String, dynamic>> earningsHistory = [];
  bool loading = true;
  double totalEarnings = 0.0;

  @override
  void initState() {
    super.initState();
    loadEarningsData();
  }

  Future<void> loadEarningsData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Load seller data
      final sellerSnapshot = await _firestore.collection("users").doc(user.uid).get();
      if (sellerSnapshot.exists) {
        setState(() {
          sellerData = sellerSnapshot.data();
        });
      }

      // Load earnings history (delivered orders)
      final ordersSnapshot = await _firestore
          .collection("orders")
          .where("sellerId", isEqualTo: user.uid)
          .where("status", isEqualTo: "Delivered")
          .orderBy("createdAt", descending: true)
          .limit(50)
          .get();

      double totalEarned = 0.0;
      final history = ordersSnapshot.docs.map((doc) {
        final data = doc.data();
        final amount = (data["totalAmount"] ?? 0).toDouble();
        totalEarned += amount;

        return {
          "id": doc.id,
          "amount": amount,
          "date": data["createdAt"]?.toDate() ?? DateTime.now(),
          "orderId": data["orderId"] ?? doc.id.substring(0, 8),
        };
      }).toList();

      setState(() {
        earningsHistory = history;
        totalEarnings = totalEarned;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: const Text(
          "Earnings Report",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Earnings Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            "Total Earnings",
                            style: TextStyle(
                              fontSize: 16,
                              color: kTextColorSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${totalEarnings.toStringAsFixed(0)} PKR",
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Earnings Breakdown
                  const Text(
                    "Earnings History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (earningsHistory.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                          "No earnings history available",
                          style: TextStyle(
                            color: kTextColorSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: earningsHistory.length,
                      itemBuilder: (context, index) {
                        final earning = earningsHistory[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.attach_money,
                              color: kPrimaryColor,
                            ),
                            title: Text(
                              "${earning["amount"]} PKR",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kTextColor,
                              ),
                            ),
                            subtitle: Text(
                              "Order #${earning["orderId"]}",
                              style: const TextStyle(
                                color: kTextColorSecondary,
                              ),
                            ),
                            trailing: Text(
                              _formatDate(earning["date"]),
                              style: const TextStyle(
                                color: kTextColorSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}