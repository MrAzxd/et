import 'dart:io';

import 'package:e/models/product_model.dart';
import 'package:e/provider/cart_provider.dart';
import 'package:e/services/firestore_service.dart';
import 'package:e/utils/constants.dart';
import 'package:e/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:provider/provider.dart';
import 'package:e/screens/buyer/cart/cart_screen.dart';

class AllShopsScreen extends StatelessWidget {
  static const String routeName = '/all-shops';

  final FirestoreService _firestoreService = FirestoreService();

  Future<bool> _showExitDialog(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App?'),
        content: const Text('Do you really want to close the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // prevent default pop
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldExit = await _showExitDialog(context);
          if (shouldExit) {
            exit(0); // Close the app
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'All Shops',
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getAllShops(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: kPrimaryColor));
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: kErrorColor)));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text('No shops available',
                      style: TextStyle(color: kTextColorSecondary)));
            }

            final shops = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'name': data['name'] ?? 'Unknown Shop',
                'sellerId': data['sellerId'],
              };
            }).toList();

            return AnimationLimiter(
              child: GridView.builder(
                padding: const EdgeInsets.all(kDefaultPadding),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: kDefaultPadding,
                  mainAxisSpacing: kDefaultPadding,
                  childAspectRatio: 1.5,
                ),
                itemCount: shops.length,
                itemBuilder: (context, index) {
                  final shop = shops[index];
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: ShopCard(
                          name: shop['name'],
                          sellerId: shop['sellerId'],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShopProductsScreen(
                                    sellerId: shop['sellerId']),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class ShopCard extends StatelessWidget {
  final String name;
  final String sellerId;
  final VoidCallback onTap;

  const ShopCard({
    super.key,
    required this.name,
    required this.sellerId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store, // Shop icon
              size: 50,
              color: kPrimaryColor,
            ),
            const SizedBox(height: kSmallPadding),
            Text(
              name,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: kTextColor,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class ShopProductsScreen extends StatelessWidget {
  static const String routeName = '/shop-products';
  final String sellerId;
  ShopProductsScreen({super.key, required this.sellerId});
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    // final sellerId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shop Products',
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
        actions: [
          Consumer<CartProvider>(
            builder: (context, value, child) {
              return IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                },
                icon: Stack(
                  children: [
                    Icon(
                      Icons.shopping_bag,
                      color: Colors.white,
                      size: 30,
                    ),
                    if (value.totalItemCount > 0)
                      Positioned(
                        right: 14,
                        top: 10,
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 8,
                          child: Text(
                            value.items.length.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getProductsBySeller(sellerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: kPrimaryColor));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: kErrorColor)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No products available',
                    style: TextStyle(color: kTextColorSecondary)));
          }

          final products = snapshot.data!.docs
              .map((doc) => ProductModel.fromSnapshot(doc))
              .toList();

          return AnimationLimiter(
            child: GridView.builder(
              padding: const EdgeInsets.all(kDefaultPadding),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: kDefaultPadding,
                mainAxisSpacing: kDefaultPadding,
                childAspectRatio: 0.75,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: 2,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: ProductCard(
                        product: product,
                        onTap: () {
                          // Navigate to product detail if needed
                        },
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
