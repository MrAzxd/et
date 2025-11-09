import 'package:e/models/product_model.dart';
import 'package:e/screens/buyer/product_detail_screen.dart';
import 'package:e/services/firestore_service.dart';
import 'package:e/utils/constants.dart';
import 'package:e/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ProductListScreen extends StatefulWidget {
  static const String routeName = '/product-list';

  final String category;

  const ProductListScreen({super.key, required this.category});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      // appBar: AppBar(
      //   title: Text(
      //     '${widget.category} Products',
      //     style: Theme.of(context).textTheme.headlineMedium!.copyWith(
      //           color: Colors.white,
      //           fontWeight: FontWeight.bold,
      //         ),
      //   ),
      //   backgroundColor: kPrimaryColor,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Colors.white),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      // ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Container(
            padding: const EdgeInsets.fromLTRB(
                kDefaultPadding, kLargePadding, kDefaultPadding, kSmallPadding),
            decoration: BoxDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category,
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        color: kTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: kSmallPadding),
                Text(
                  'Explore products in this category',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: kTextColorSecondary,
                      ),
                ),
              ],
            ),
          ),
          // Search Bar and Sort Button
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: kDefaultPadding, vertical: kSmallPadding),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search in ${widget.category}...',
                      prefixIcon:
                          const Icon(Icons.search, color: kPrimaryColor),
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
                        borderSide:
                            BorderSide(color: kBorderColor.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(kDefaultBorderRadius),
                        borderSide:
                            const BorderSide(color: kPrimaryColor, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Trigger rebuild to filter products
                    },
                  ),
                ),
                const SizedBox(width: kSmallPadding),
                AnimatedScaleButton(
                  child: IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              const Text('Sorting functionality coming soon!'),
                          backgroundColor: kPrimaryColor,
                        ),
                      );
                    },
                    icon: const Icon(Icons.sort, color: kPrimaryColor),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(kDefaultBorderRadius),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Product Grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getProductsByCategory(widget.category),
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
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No products found in this category',
                      style: TextStyle(color: kTextColorSecondary),
                    ),
                  );
                }

                final products = snapshot.data!.docs
                    .map((doc) => ProductModel.fromSnapshot(doc))
                    .toList()
                    .where((product) => product.name
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase()))
                    .toList();

                return AnimationLimiter(
                  child: GridView.builder(
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
                  ),
                );
              },
            ),
          ),
        ],
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
