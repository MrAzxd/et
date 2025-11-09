import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Order Info
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.receipt_long, color: Colors.teal),
                title: const Text("Order #12345"),
                subtitle: const Text("Placed on: 02 Oct 2025"),
                trailing: const Chip(
                  label: Text("Delivered"),
                  backgroundColor: Colors.greenAccent,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Shipping Info
            const Text("Shipping Address",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Card(
              child: ListTile(
                leading: Icon(Icons.location_on, color: Colors.redAccent),
                title: Text("Azad Ali"),
                subtitle: Text("123, Karachi, Pakistan"),
              ),
            ),
            const SizedBox(height: 20),

            // Items Ordered
            const Text("Items",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Card(
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.fastfood),
                    title: Text("Cheese Pizza"),
                    subtitle: Text("Size: Medium"),
                    trailing: Text("x1   \$12"),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.fastfood),
                    title: Text("Zinger Burger"),
                    subtitle: Text("With extra cheese"),
                    trailing: Text("x2   \$10"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Payment Info
            const Text("Payment",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Card(
              child: ListTile(
                leading: Icon(Icons.payment, color: Colors.blueAccent),
                title: Text("Paid via Credit Card"),
                trailing: Text("\$32"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
