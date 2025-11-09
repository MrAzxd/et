import 'package:e/models/product_model.dart';
import 'package:e/models/shop_model.dart';
import 'package:e/screens/auth/login_screen.dart';

import 'package:e/screens/seller/orders.dart';
import 'package:e/screens/seller/product_edit_screen.dart';
import 'package:e/screens/seller/product_upload_screen.dart';
import 'package:e/provider/orderprovider.dart';
import 'package:e/services/firestore_service.dart';
import 'package:e/utils/constants.dart';
import 'package:e/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class SellerDashboardScreen extends StatefulWidget {
  static const String routeName = '/seller-dashboard';

  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  ShopModel? _shop;

  @override
  void initState() {
    super.initState();
    _loadShop();
  }

  Future<void> _loadShop() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await _firestoreService.getUserData(user.uid);
        final shopId = userData?['shopId'];
        if (shopId != null) {
          final shop = await _firestoreService.getShop(shopId);
          setState(() {
            _shop = shop;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error loading shop: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: kErrorColor,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _shop != null ? _shop!.name : 'Seller Dashboard',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        actions: [
          OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white)),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrdersScreen(),
                    ));
              },
              icon: Icon(
                Icons.shop_sharp,
                color: Colors.white,
              ),
              label: Text('See Orders')),
          SizedBox(
            width: 8,
          ),
          Consumer<OrdersProvider>(
            builder: (context, ordersProvider, child) {
              final pendingCount = ordersProvider.statusCounts['Pending'] ?? 0;
              return pendingCount > 0
                  ? CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 13,
                      child: Text(
                        '$pendingCount',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(color: Colors.white, fontSize: 15),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            },
          ),
        ],
      ),
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
        child: _shop == null
            ? const Center(
                child: CircularProgressIndicator(color: kPrimaryColor))
            : AnimationLimiter(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        // Shop Info Card
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                kDefaultBorderRadius * 1.5),
                          ),
                          margin: const EdgeInsets.all(kDefaultPadding),
                          child: Padding(
                            padding: const EdgeInsets.all(kDefaultPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _shop!.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!
                                      .copyWith(
                                        color: kTextColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: kSmallPadding),
                                Text(
                                  _shop!.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        color: kTextColorSecondary,
                                      ),
                                ),
                                const SizedBox(height: kDefaultPadding),
                                AnimatedScaleButton(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          kPrimaryColor,
                                          kPrimaryColor.withOpacity(0.8)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          kDefaultBorderRadius),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context,
                                            ProductUploadScreen.routeName);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              kDefaultBorderRadius),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 32,
                                        ),
                                      ),
                                      child: const Text(
                                        'Add New Product',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: kDefaultPadding,
                            vertical: kSmallPadding,
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search your products...',
                              prefixIcon: const Icon(Icons.search,
                                  color: kPrimaryColor),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(kDefaultBorderRadius),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(kDefaultBorderRadius),
                                borderSide: BorderSide(
                                    color: kBorderColor.withOpacity(0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(kDefaultBorderRadius),
                                borderSide: const BorderSide(
                                    color: kPrimaryColor, width: 2),
                              ),
                            ),
                            onChanged: (value) {
                              setState(
                                  () {}); // Trigger rebuild to filter products
                            },
                          ),
                        ),
                        // Products List
                        StreamBuilder<QuerySnapshot>(
                          stream:
                              _firestoreService.getProductsByShop(_shop!.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                    color: kPrimaryColor),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error: ${snapshot.error}',
                                  style: const TextStyle(color: kErrorColor),
                                ),
                              );
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No products available',
                                  style: TextStyle(color: kTextColorSecondary),
                                ),
                              );
                            }

                            final products = snapshot.data!.docs
                                .map((doc) => ProductModel.fromSnapshot(doc))
                                .toList()
                                .where((product) => product.name
                                    .toLowerCase()
                                    .contains(
                                        _searchController.text.toLowerCase()))
                                .toList();

                            return AnimationLimiter(
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(kDefaultPadding),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
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
                                        child: AnimatedScaleButton(
                                          child: ProductCardShoper(
                                            product: product,
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                ProductEditScreen.routeName,
                                                arguments: product,
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
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

// Custom widget for button tap animation
class AnimatedScaleButton extends StatefulWidget {
  final Widget child;

  const AnimatedScaleButton({super.key, required this.child});

  @override
  State<AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
