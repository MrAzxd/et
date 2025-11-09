import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e/screens/buyer/single_order.dart';
import 'package:e/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class OrderHistoryScreen extends StatelessWidget {
  static const String routeName = '/order-history';

  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          title: const Text('Order History'),
          backgroundColor: kPrimaryColor,
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            'Please log in to view your orders',
            style: TextStyle(fontSize: 18, color: kTextColor),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Order History'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1B5E20), // dark green
                // medium green
                Color(0xFF66BB6A),
                Color(0xFF2E7D32), // light green
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            // .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('${user.uid} >>>>>>>>>>>>>>>>>>>>>>>>');
            // Log error for debugging
            debugPrint('Firestore error: ${snapshot.error}');
            return const Center(
              child: Text(
                'Error loading orders. Please try again.',
                style: TextStyle(fontSize: 18, color: kTextColor),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No orders found',
                style: TextStyle(fontSize: 18, color: kTextColor),
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(kDefaultPadding),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final orderData = orders[index].data() as Map<String, dynamic>?;
                final orderId = orders[index].id;

                // Validate order data
                if (orderData == null ||
                    !orderData.containsKey('createdAt') ||
                    !orderData.containsKey('status') ||
                    !orderData.containsKey('totalAmount')) {
                  return const SizedBox.shrink(); // Skip invalid orders
                }

                final createdAt = (orderData['createdAt'] is Timestamp)
                    ? (orderData['createdAt'] as Timestamp).toDate()
                    : DateTime.now();
                final status = orderData['status']?.toString() ?? 'Unknown';
                final total = (orderData['totalAmount'] is num)
                    ? (orderData['totalAmount'] as num).toDouble()
                    : 0.0;

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: kDefaultPadding,
                          vertical: kSmallPadding,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(kDefaultBorderRadius),
                        ),
                        elevation: 3,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: kPrimaryColor.withOpacity(0.1),
                            child: const Icon(Icons.shopping_bag,
                                color: kPrimaryColor),
                          ),
                          title: Text(
                              'Order #${orderId.length > 8 ? orderId.substring(0, 8) : orderId}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                              ),
                              Text(
                                'Status: $status',
                                style: TextStyle(
                                  color: status == 'Delivered'
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
                                                          : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Total: Rs. ${total.toStringAsFixed(2)}'),
                            ],
                          ),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OrderDetailScreen(orderId: orderId),
                              ),
                            );
                          },
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
}
