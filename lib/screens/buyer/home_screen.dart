import 'package:e/models/product_model.dart';
import 'package:e/provider/cart_provider.dart';
import 'package:e/screens/buyer/cart/cart_screen.dart';
import 'package:e/screens/buyer/product_detail_screen.dart';
import 'package:e/screens/buyer/product_list_screen.dart';
import 'package:e/screens/buyer/search.dart';
import 'package:e/screens/buyer/slider.dart';
import 'package:e/screens/profile/User_profile.dart';
import 'package:e/services/firestore_service.dart';
import 'package:e/utils/constants.dart';
import 'package:e/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedCategory = kProductCategories.first;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      drawer: const ProfileScreen(),
      appBar: AppBar(
        title: Text(
          kAppName,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1B5E20), // dark green
                Color(0xFF66BB6A), // medium green
                Color(0xFF2E7D32), // light green
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        actions: [
          // SEARCH ICON
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          // CART ICON
          Consumer<CartProvider>(
            builder: (context, value, child) {
              return IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
                icon: Stack(
                  children: [
                    const Icon(Icons.shopping_bag,
                        color: Colors.white, size: 30),
                    if (cart.totalItemCount > 0)
                      Positioned(
                        right: 14,
                        top: 10,
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 8,
                          child: Text(
                            value.items.length.toString(),
                            style: const TextStyle(
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
          const SizedBox(width: 10),
        ],
      ),
      // ---------------------------------------------------------
      //  ONE BIG SCROLLABLE AREA
      // ---------------------------------------------------------
      body: CustomScrollView(
        slivers: [
          // ----- WELCOME TEXT -----
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                kDefaultPadding,
                16.h,
                kDefaultPadding,
                8.h,
              ),
              child: Text(
                'Category',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: kTextColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),

          // ----- CATEGORY HORIZONTAL LIST -----
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: kSmallPadding,
                horizontal: kDefaultPadding,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double screenWidth = constraints.maxWidth;
                  final double minCardWidth = 65.w;
                  final double maxCardWidth = 100.w;
                  final double availableWidth =
                      screenWidth - (2 * kDefaultPadding);
                  final int maxVisibleCards = (availableWidth / minCardWidth)
                      .floor()
                      .clamp(1, kProductCategories.length);

                  double cardWidth = availableWidth / maxVisibleCards;
                  cardWidth = cardWidth.clamp(minCardWidth, maxCardWidth);

                  return SizedBox(
                    height:
                        cardWidth + 10.h, // Dynamic height based on card width
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: kProductCategories.length,
                      itemBuilder: (context, index) {
                        final categoryImage = imagenames[index];
                        final category = kProductCategories[index];

                        return Padding(
                          padding: EdgeInsets.only(right: kSmallPadding),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedCategory = category);
                              Navigator.pushNamed(
                                context,
                                ProductListScreen.routeName,
                                arguments: category,
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: cardWidth,
                              padding: EdgeInsets.symmetric(
                                vertical: 2.h,
                                horizontal: 2.w,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(kDefaultBorderRadius),
                                border: Border.all(color: kBorderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Responsive Image (scaled to card)
                                  SizedBox(
                                    height: cardWidth * 0.45,
                                    width: cardWidth * 0.45,
                                    child: Image.asset(
                                      'assets/${categoryImage.toLowerCase()}.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.category,
                                        size: cardWidth * 0.45,
                                        color: kPrimaryColor.withOpacity(0.6),
                                      ),
                                    ),
                                  ),

                                  // Responsive Text
                                  Flexible(
                                    child: Text(
                                      category,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: (cardWidth * 0.13)
                                            .sp
                                            .clamp(10.0, 13.0),
                                        color: kTextColor,
                                        fontWeight: FontWeight.w500,
                                        height: 1.1,
                                      ),
                                    ),
                                  ),
                                ],
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
          ),

          // ----- SPACER -----
          SliverToBoxAdapter(child: SizedBox(height: 10.h)),

          // ----- IMAGE SLIDER -----
          const SliverToBoxAdapter(child: HomeImageSlider()),

          // ——————————— POPULAR PRODUCTS LABEL ———————————
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                kDefaultPadding,
                16.h,
                kDefaultPadding,
                8.h,
              ),
              child: Text(
                'Popular products',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: kTextColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),

// ——————————— HORIZONTAL POPULAR PRODUCTS ———————————
          SliverToBoxAdapter(
            child: SizedBox(
              height: 240.h, // Card height + padding
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestoreService.getProductsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No popular products',
                        style: TextStyle(
                            color: kTextColorSecondary, fontSize: 14.sp),
                      ),
                    );
                  }

                  final products = snapshot.data!.docs
                      .map((doc) => ProductModel.fromSnapshot(doc))
                      .toList();

                  // For now: show all products (you can filter later)
                  // Example: .take(10).toList() to limit

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];

                      return Padding(
                        padding: EdgeInsets.only(right: kDefaultPadding),
                        child: SizedBox(
                          width:
                              140.w, // Fixed card width for horizontal scroll
                          child: ProductCard(
                            product: product,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                ProductDetailScreen.routeName,
                                arguments: product,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // ----- SPACER -----
          SliverToBoxAdapter(child: SizedBox(height: 10.h)),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                kDefaultPadding,
                16.h,
                kDefaultPadding,
                8.h,
              ),
              child: Text(
                'Just for you',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: kTextColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),

          // ----- PRODUCT GRID (scrolls with everything above) -----
          StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getProductsStream(),
            builder: (context, snapshot) {
              // Loading / error / empty
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  ),
                );
              }
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: kErrorColor),
                    ),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No products available',
                      style: TextStyle(color: kTextColorSecondary),
                    ),
                  ),
                );
              }

              final products = snapshot.data!.docs
                  .map((doc) => ProductModel.fromSnapshot(doc))
                  .toList();

              return SliverPadding(
                padding: EdgeInsets.all(kDefaultPadding),
                sliver: AnimationLimiter(
                  child: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: kDefaultPadding,
                      mainAxisSpacing: kDefaultPadding,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];
                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          columnCount: 2,
                          child: ScaleAnimation(
                            child: FadeInAnimation(
                              child: Hero(
                                tag: 'product_${product.id}',
                                child: ProductCard(
                                  product: product,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      ProductDetailScreen.routeName,
                                      arguments: product,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
