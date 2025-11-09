// lib/screens/admin/order_detail_screen.dart
import 'package:e/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
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
      backgroundColor: kBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              kPrimaryColor.withOpacity(0.1),
              kBackgroundColor,
            ],
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .doc(orderId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: kPrimaryColor));
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: kErrorColor),
                ),
              );
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text(
                  'Order not found',
                  style: TextStyle(color: kTextColorSecondary),
                ),
              );
            }

            final orderData = snapshot.data!.data() as Map<String, dynamic>?;
            if (orderData == null ||
                !orderData.containsKey('createdAt') ||
                !orderData.containsKey('items') ||
                !orderData.containsKey('shippingDetails') ||
                !orderData.containsKey('totalAmount')) {
              return const Center(
                child: Text(
                  'Invalid order data',
                  style: TextStyle(color: kTextColorSecondary),
                ),
              );
            }

            final items = (orderData['items'] as List<dynamic>)
                .map((item) => item as Map<String, dynamic>)
                .toList();
            final shippingDetails =
                orderData['shippingDetails'] as Map<String, dynamic>;
            final createdAt = (orderData['createdAt'] as Timestamp).toDate();
            final total = (orderData['totalAmount'] as num).toDouble();
            final status = orderData['status'] as String? ?? 'Unknown';

            return AnimationLimiter(
              child: ListView(
                padding: const EdgeInsets.all(kDefaultPadding),
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    // Order Header
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(kDefaultBorderRadius),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(kDefaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #$orderId',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: kTextColor,
                                  ),
                            ),
                            const SizedBox(height: kSmallPadding),
                            Text(
                              'Placed on: ${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute}',
                              style:
                                  const TextStyle(color: kTextColorSecondary),
                            ),
                            const SizedBox(height: kDefaultPadding),
                            Text(
                              'Status: $status',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
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
                                                            : kPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: kDefaultPadding),
                    // Shipping Details
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(kDefaultBorderRadius),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(kDefaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shipping Details',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: kTextColor,
                                  ),
                            ),
                            const SizedBox(height: kSmallPadding),
                            Text(
                                'Name: ${shippingDetails['name'] ?? 'Unknown'}'),
                            Text(
                                'Email: ${shippingDetails['email'] ?? 'Unknown'}'),
                            Text(
                                'Address: ${shippingDetails['address'] ?? 'Unknown'}'),
                            Text(
                                'City: ${shippingDetails['city'] ?? 'Unknown'}'),
                            Text('ZIP: ${shippingDetails['zip'] ?? 'Unknown'}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: kDefaultPadding),
                    // Order Items
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(kDefaultBorderRadius),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(kDefaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Items',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: kTextColor,
                                  ),
                            ),
                            const SizedBox(height: kSmallPadding),
                            ...items.map((item) => ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      item['imageUrl'] ?? '',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.error,
                                                  color: Colors.red),
                                    ),
                                  ),
                                  title: Text(item['productName'] ?? 'Unknown'),
                                  subtitle: Text(
                                    '\$${item['price']?.toStringAsFixed(2) ?? '0.00'} x ${item['quantity'] ?? 0}',
                                    style: const TextStyle(
                                        color: kTextColorSecondary),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: kDefaultPadding),
                    // Total
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(kDefaultBorderRadius),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(kDefaultPadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: kTextColor,
                                  ),
                            ),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
