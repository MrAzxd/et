import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget sellerDashboard() {
  final user = FirebaseAuth.instance.currentUser;

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Dashboard Overview",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16.h),

        /// ---- ROW OF CARDS ----
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// -------------------- SELLER'S PRODUCTS --------------------
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .where('sellerId', isEqualTo: user?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return DashboardCard(
                      title: "My Products",
                      value: "...",
                      icon: Icons.inventory_2,
                      color: Colors.orange,
                    );
                  }

                  int productCount = snapshot.data!.docs.length;

                  return DashboardCard(
                    title: "My Products",
                    value: "$productCount",
                    icon: Icons.inventory_2,
                    color: Colors.orange,
                  );
                },
              ),
            ),

            SizedBox(width: 12.w),

            /// -------------------- SELLER'S ORDERS --------------------
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .where('sellerId', isEqualTo: user?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return DashboardCard(
                      title: "My Orders",
                      value: "...",
                      icon: Icons.shopping_cart,
                      color: Colors.blue,
                    );
                  }

                  int orderCount = snapshot.data!.docs.length;

                  return DashboardCard(
                    title: "My Orders",
                    value: "$orderCount",
                    icon: Icons.shopping_cart,
                    color: Colors.blue,
                  );
                },
              ),
            ),
          ],
        ),

        SizedBox(height: 16.h),

        /// ---- SECOND ROW OF CARDS ----
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// -------------------- TOTAL EARNINGS --------------------
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .where('sellerId', isEqualTo: user?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return DashboardCard(
                      title: "Earnings",
                      value: "...",
                      icon: Icons.currency_rupee,
                      color: Colors.green,
                    );
                  }

                  double totalEarning = 0.0;
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['totalAmount'] != null) {
                      totalEarning += (data['totalAmount'] as num).toDouble();
                    }
                  }

                  return DashboardCard(
                    title: "Earnings",
                    value: "Rs. ${totalEarning.toStringAsFixed(0)}",
                    icon: Icons.currency_rupee,
                    color: Colors.green,
                  );
                },
              ),
            ),

            SizedBox(width: 12.w),

            /// -------------------- PENDING ORDERS --------------------
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .where('sellerId', isEqualTo: user?.uid)
                    .where('status', isEqualTo: 'Pending')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return DashboardCard(
                      title: "Pending",
                      value: "...",
                      icon: Icons.pending,
                      color: Colors.red,
                    );
                  }

                  int pendingCount = snapshot.data!.docs.length;

                  return DashboardCard(
                    title: "Pending",
                    value: "$pendingCount",
                    icon: Icons.pending,
                    color: Colors.red,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class DashboardCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;

  DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      child: Container(
        padding: EdgeInsets.all(16.w),
        height: 120.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22.r,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 28.sp, color: color),
            ),
            Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
