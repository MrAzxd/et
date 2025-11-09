import 'package:cached_network_image/cached_network_image.dart';
import 'package:e/Messages/MasssageScreen.dart';
import 'package:e/models/product_model.dart';
import 'package:e/provider/cart_provider.dart';
import 'package:e/provider/wishlist_provider.dart';
import 'package:e/screens/buyer/cart/cart_screen.dart';
import 'package:e/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  static const String routeName = '/product-detail';

  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final wishlist = Provider.of<WishlistProvider>(context);
    final isFavorite =
        wishlist.items.any((item) => item.id == widget.product.id);
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        actions: [
          Consumer<CartProvider>(
            builder: (context, value, child) {
              return IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartScreen(),
                        ));
                  },
                  icon: Stack(
                    children: [
                      Icon(
                        Icons.shopping_bag,
                        color: Colors.white,
                        size: 30,
                      ),
                      if (cart.totalItemCount > 0)
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
                            )),
                      SizedBox(
                        width: 10,
                      )
                    ],
                  ));
            },
          ),
        ],
        title: Text(
          widget.product.name,
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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimationLimiter(
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
                // Product Image
                Stack(
                  children: [
                    Hero(
                      tag: 'product_${widget.product.id}',
                      child: Container(
                        height: 350,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                              widget.product.imageUrl,
                              errorListener: (exception) =>
                                  const NetworkImage(kDefaultImageUrl),
                            ),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft:
                                Radius.circular(kDefaultBorderRadius * 2),
                            bottomRight:
                                Radius.circular(kDefaultBorderRadius * 2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 350,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            kPrimaryColor.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                    // Heart Icon Button
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 30,
                        ),
                        onPressed: () async {
                          if (isFavorite) {
                            await wishlist.removeItem(widget.product.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${widget.product.name} removed from wishlist!')),
                            );
                          } else {
                            await wishlist.addItem(widget.product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${widget.product.name} added to wishlist!')),
                            );
                          }
                          setState(() {}); // Refresh the icon state
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedScaleButton(
                              child: ElevatedButton(
                                onPressed: () {
                                  final cart = Provider.of<CartProvider>(
                                      context,
                                      listen: false);
                                  cart.addItem(widget.product,
                                      _quantity); // Just add — no seller check
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            '${widget.product.name} added to cart!')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: kPrimaryColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        kDefaultBorderRadius),
                                  ),
                                ),
                                child: const Text('Add to Cart'),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 10,
                      ),
                      // Product Name
                      Text(
                        widget.product.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              color: kTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: kSmallPadding),
                      // Price and Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${widget.product.price.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Row(
                            children: [
                              // const Icon(Icons.star,
                              //     color: Colors.amber, size: 20),
                              // const SizedBox(width: kSmallPadding / 2),
                              // Text(
                              //   '4.5', // Placeholder for future rating
                              //   style: Theme.of(context)
                              //       .textTheme
                              //       .bodyLarge!
                              //       .copyWith(
                              //         color: kTextColorSecondary,
                              //       ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: kDefaultPadding),
                      // Category
                      Row(
                        children: [
                          const Icon(Icons.category,
                              color: kTextColorSecondary),
                          const SizedBox(width: kSmallPadding),
                          Text(
                            widget.product.category,
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: kTextColorSecondary,
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: kDefaultPadding),
                      // Quantity Selector
                      Row(
                        children: [
                          Text(
                            'Quantity:',
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: kTextColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                          const SizedBox(width: kSmallPadding),
                          IconButton(
                            onPressed: () {
                              if (_quantity > 1) {
                                setState(() {
                                  _quantity--;
                                });
                              }
                            },
                            icon: const Icon(Icons.remove_circle,
                                color: kPrimaryColor),
                          ),
                          Text(
                            '$_quantity',
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: kTextColor,
                                    ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _quantity++;
                              });
                            },
                            icon: const Icon(Icons.add_circle,
                                color: kPrimaryColor),
                          ),
                        ],
                      ),

                      // Shop Name and Icons
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: kSmallPadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.store,
                                    color: kTextColorSecondary),
                                const SizedBox(width: kSmallPadding),
                                Text(
                                  '${widget.product.sellerName}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!
                                      .copyWith(
                                        color: kTextColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                //add massages functions here
                                IconButton(
                                  icon: const Icon(Icons.sms,
                                      color: kPrimaryColor),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        receiverId: widget.product.sellerId,
                                        receiverName: widget.product.sellerName,
                                      ),
                                    ));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('chat open')),
                                    );
                                    // Placeholder for Visit Shop action
                                  },
                                  tooltip: 'Chat with Seller',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward,
                                      color: kPrimaryColor),
                                  onPressed: () {
                                    // Placeholder for Chat action
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Visit Shop feature coming soon!')),
                                    );
                                  },
                                  tooltip: 'Visit Shop',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // const SizedBox(height: kDefaultPadding),
                      // Description
                      Text(
                        'Description',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              color: kTextColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: kSmallPadding),
                      Text(
                        widget.product.description,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: kTextColorSecondary,
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: kLargePadding),
                      // Action Buttons
                    ],
                  ),
                ),
              ],
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
