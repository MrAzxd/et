import 'package:e/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';


// Constants for styling
// const kBackgroundColor = Colors.white;
// const kPrimaryColor = Colors.teal;
// const kTextColor = Colors.black;
const kTextColorSecondary = Colors.grey;
const kDefaultPadding = 12.0;
const kSmallPadding = 6.0;
const kDefaultBorderRadius = 12.0;

class OrdersDemoScreen extends StatelessWidget {
  const OrdersDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          title: const Text('Orders', style: TextStyle(color: Colors.white)),
          backgroundColor: kPrimaryColor,
        ),
        body: const Center(
          child: Text(
            'Please log in to view orders',
            style: TextStyle(fontSize: 18, color: kTextColor),
          ),
        ),
      );
    }

    // For demo, assume sellerId = user.uid
    final sellerId = user.uid;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Orders', style: TextStyle(color: Colors.white)),
        backgroundColor: kPrimaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('sellerId', isEqualTo: sellerId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No orders found'),
            );
          }

          // Group orders by status
          final docs = snapshot.data!.docs;
          final Map<String, List<QueryDocumentSnapshot>> groupedOrders = {};
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'Pending';
            groupedOrders.putIfAbsent(status, () => []).add(doc);
          }

          final statuses = [
            'Pending',
            'Processing',
            'Shipped',
            'Delivered',
            'Cancelled',
            'Returned'
          ];

          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(kDefaultPadding),
              itemCount: statuses.length,
              itemBuilder: (context, index) {
                final status = statuses[index];
                final orders = groupedOrders[status] ?? [];

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 400),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Card(
                        margin:
                            const EdgeInsets.symmetric(vertical: kSmallPadding),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                        ),
                        elevation: 3,
                        child: ExpansionTile(
                          initiallyExpanded: orders.isNotEmpty,
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(status).withOpacity(0.2),
                            child: Icon(Icons.shopping_bag, color: _getStatusColor(status)),
                          ),
                          title: Text(
                            '$status (${orders.length})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kTextColor,
                            ),
                          ),
                          children: orders.map((doc) {
                            final orderData = doc.data() as Map<String, dynamic>;
                            final createdAt = (orderData['createdAt'] as Timestamp)
                                .toDate();
                            final total = (orderData['totalAmount'] as num?)?.toDouble() ?? 0;

                            return ListTile(
                              title: Text('Order #${doc.id.substring(0, 8)}'),
                              subtitle: Text(
                                  'Placed on: ${createdAt.day}/${createdAt.month}/${createdAt.year}\nTotal: \$${total.toStringAsFixed(2)}'),
                              trailing: Text(
                                status,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(status)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    return status == 'Delivered'
        ? Colors.green
        : status == 'Pending'
            ? Colors.orange
            : status == 'Processing'
                ? Colors.blue
                : status == 'Shipped'
                    ? Colors.purple
                    : status == 'Cancelled'
                        ? Colors.red
                        : status == 'Returned'
                            ? Colors.deepOrange
                            : kPrimaryColor;
  }
}
