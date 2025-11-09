import 'package:e/models/product_model.dart';
import 'package:e/provider/wishlist_provider.dart';
import 'package:e/screens/buyer/product_detail_screen.dart';

import 'package:e/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WishlistScreen extends StatelessWidget {
  static const String routeName = '/wishlist';

  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = Provider.of<WishlistProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Wishlist'),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: () async {
              //confrom alert
              await wishlist.clearWishlist();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Wishlist cleared!')),
              );
            },
          ),
        ],
      ),
      body: wishlist.items.isEmpty
          ? const Center(child: Text('Your wishlist is empty'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: wishlist.items.length,
              itemBuilder: (context, index) {
                final item = wishlist.items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: Image.network(
                      item.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                    ),
                    title: Text(item.name),
                    subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => wishlist.removeItem(item.id),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailScreen(product: item),
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
