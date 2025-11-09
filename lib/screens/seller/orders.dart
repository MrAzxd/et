import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e/provider/orderprovider.dart';
import 'package:e/utils/constants.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatelessWidget {
  static const String routeName = '/orders';

  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          title: const Text('Orders', style: TextStyle(color: Colors.white)),
          backgroundColor: kPrimaryColor,
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            'Please log in to view orders',
            style: TextStyle(fontSize: 18, color: kTextColor),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Orders', style: TextStyle(color: Colors.white)),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: Consumer<OrdersProvider>(
        builder: (context, ordersProvider, child) {
          final statusCounts = ordersProvider.statusCounts;

          return AnimationLimiter(
            child: Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: ListView(
                children: [
                  _buildStatusCard(
                    context,
                    status: 'Pending',
                    count: statusCounts['Pending'] ?? 0,
                    color: Colors.orange,
                    index: 0,
                  ),
                  _buildStatusCard(
                    context,
                    status: 'Processing',
                    count: statusCounts['Processing'] ?? 0,
                    color: Colors.blue,
                    index: 1,
                  ),
                  _buildStatusCard(
                    context,
                    status: 'Shipped',
                    count: statusCounts['Shipped'] ?? 0,
                    color: Colors.purple,
                    index: 2,
                  ),
                  _buildStatusCard(
                    context,
                    status: 'Delivered',
                    count: statusCounts['Delivered'] ?? 0,
                    color: Colors.green,
                    index: 3,
                  ),
                  _buildStatusCard(
                    context,
                    status: 'Cancelled',
                    count: statusCounts['Cancelled'] ?? 0,
                    color: Colors.red,
                    index: 4,
                  ),
                  _buildStatusCard(
                    context,
                    status: 'Returned',
                    count: statusCounts['Returned'] ?? 0,
                    color: Colors.deepOrange,
                    index: 5,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required String status,
    required int count,
    required Color color,
    required int index,
  }) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: kSmallPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kDefaultBorderRadius),
            ),
            elevation: 3,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(Icons.shopping_bag, color: color),
              ),
              title: Text(
                status,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
              ),
              subtitle: Text(
                '$count order${count == 1 ? '' : 's'}',
                style: const TextStyle(color: kTextColorSecondary),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatusOrdersScreen(status: status),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class StatusOrdersScreen extends StatefulWidget {
  final String status;
  const StatusOrdersScreen({super.key, required this.status});
  @override
  State<StatusOrdersScreen> createState() => _StatusOrdersScreenState();
}

class _StatusOrdersScreenState extends State<StatusOrdersScreen> {
  late Future<String?> _sellerIdFuture;

  @override
  void initState() {
    super.initState();
    _sellerIdFuture = _fetchSellerId();
  }

  Future<String?> _fetchSellerId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) return null;
      return doc.data()?['sellerId'] as String?;
    } catch (e) {
      debugPrint('Error fetching sellerId: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text('${widget.status} Orders',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: FutureBuilder<String?>(
        future: _sellerIdFuture,
        builder: (context, snapshot) {
          // Loading sellerId
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // No sellerId → no access
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text(
                'No seller profile found',
                style: TextStyle(fontSize: 18, color: kTextColor),
              ),
            );
          }

          final sellerId = snapshot.data!;

          // Now stream only THIS seller's orders
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('status', isEqualTo: widget.status)
                .where('sellerId', isEqualTo: sellerId)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                debugPrint(
                    'Error loading ${widget.status} orders: ${snapshot.error}');
                return const Center(
                  child: Text('Error loading orders',
                      style: TextStyle(fontSize: 18, color: kTextColor)),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No orders found',
                      style: TextStyle(fontSize: 18, color: kTextColor)),
                );
              }

              final orders = snapshot.data!.docs;

              return AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final orderData =
                        orders[index].data() as Map<String, dynamic>?;
                    final orderId = orders[index].id;

                    if (orderData == null ||
                        !orderData.containsKey('createdAt') ||
                        !orderData.containsKey('items') ||
                        !orderData.containsKey('shippingDetails') ||
                        !orderData.containsKey('totalAmount')) {
                      return const SizedBox.shrink();
                    }

                    final items = (orderData['items'] as List<dynamic>)
                        .map((item) => item as Map<String, dynamic>)
                        .toList();
                    final shippingDetails =
                        orderData['shippingDetails'] as Map<String, dynamic>;
                    final createdAt = (orderData['createdAt'] is Timestamp)
                        ? (orderData['createdAt'] as Timestamp).toDate()
                        : DateTime.now();
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
                                vertical: kSmallPadding),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(kDefaultPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order #${orderId.length > 8 ? orderId.substring(0, 8) : orderId}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: kTextColor,
                                        ),
                                  ),
                                  const SizedBox(height: kSmallPadding),
                                  Text(
                                    'Placed on: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                                    style: const TextStyle(
                                        color: kTextColorSecondary),
                                  ),
                                  const SizedBox(height: kDefaultPadding),
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
                                  Text(
                                      'Name: ${shippingDetails['name'] ?? 'Unknown'}'),
                                  Text(
                                      'Email: ${shippingDetails['email'] ?? 'Unknown'}'),
                                  Text(
                                      'Address: ${shippingDetails['address'] ?? 'Unknown'}'),
                                  Text(
                                      'City: ${shippingDetails['city'] ?? 'Unknown'}'),
                                  Text(
                                      'ZIP: ${shippingDetails['zip'] ?? 'Unknown'}'),
                                  const SizedBox(height: kDefaultPadding),
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
                                  ...items.map((item) => ListTile(
                                        leading: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            item['imageUrl'] ?? '',
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.error,
                                                    color: Colors.red),
                                          ),
                                        ),
                                        title: Text(
                                            item['productName'] ?? 'Unknown'),
                                        subtitle: Text(
                                          '\$${item['price']?.toStringAsFixed(2) ?? '0.00'} × ${item['quantity'] ?? 0}',
                                          style: const TextStyle(
                                              color: kTextColorSecondary),
                                        ),
                                      )),
                                  const SizedBox(height: kDefaultPadding),
                                  Text(
                                    'Total: \$${total.toStringAsFixed(2)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: kPrimaryColor,
                                        ),
                                  ),
                                  const SizedBox(height: kDefaultPadding),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Status: ${widget.status}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                              color: _getStatusColor(
                                                  widget.status),
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      DropdownButton<String>(
                                        value: widget.status,
                                        items: const [
                                          DropdownMenuItem(
                                              value: 'Pending',
                                              child: Text('Pending')),
                                          DropdownMenuItem(
                                              value: 'Processing',
                                              child: Text('Processing')),
                                          DropdownMenuItem(
                                              value: 'Shipped',
                                              child: Text('Shipped')),
                                          DropdownMenuItem(
                                              value: 'Delivered',
                                              child: Text('Delivered')),
                                          DropdownMenuItem(
                                              value: 'Cancelled',
                                              child: Text('Cancelled')),
                                          DropdownMenuItem(
                                              value: 'Returned',
                                              child: Text('Returned')),
                                        ],
                                        onChanged: (newStatus) {
                                          if (newStatus != null &&
                                              newStatus != widget.status) {
                                            updateOrderStatus(
                                                context, orderId, newStatus);
                                          }
                                        },
                                        style:
                                            const TextStyle(color: kTextColor),
                                        dropdownColor: kBackgroundColor,
                                        underline: const SizedBox(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
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

Future<void> updateOrderStatus(
    BuildContext context, String orderId, String newStatus) async {
  try {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'status': newStatus});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order status updated to $newStatus'),
        backgroundColor: kPrimaryColor,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error updating status: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
