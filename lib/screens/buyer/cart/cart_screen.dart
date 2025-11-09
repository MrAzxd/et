import 'package:e/models/product_model.dart';
import 'package:e/provider/cart_provider.dart';
import 'package:e/screens/buyer/cart/checkout_screen.dart';
import 'package:e/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CartScreen extends StatelessWidget {
  static const String routeName = '/cart';

  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Cart',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1B5E20),
                Color(0xFF66BB6A),
                Color(0xFF2E7D32),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          final groupedCarts = cart.groupedCarts;

          if (cart.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, color: kTextColor),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cart Items by Shop
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(kDefaultPadding.w),
                  itemCount: groupedCarts.length,
                  itemBuilder: (context, index) {
                    final sellerId = groupedCarts.keys.elementAt(index);
                    final group = groupedCarts[sellerId]!;

                    return ShopCartSection(group: group);
                  },
                ),
              ),

              // Grand Total & Checkout
              Container(
                padding: EdgeInsets.all(kDefaultPadding.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total (${cart.totalItemCount} items)',
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: kTextColor,
                                  ),
                        ),
                        Text(
                          '\$${cart.grandTotal.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryColor,
                                  ),
                        ),
                      ],
                    ),
                    SizedBox(height: kDefaultPadding.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => CheckoutScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(kDefaultBorderRadius),
                          ),
                        ),
                        child: Text(
                          'Proceed to Checkout',
                          style:
                              TextStyle(fontSize: 16.sp, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Shop Section Widget
class ShopCartSection extends StatelessWidget {
  final CartGroup group;

  const ShopCartSection({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Card(
      margin: EdgeInsets.only(bottom: kDefaultPadding.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
      ),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(kDefaultBorderRadius)),
            ),
            child: Row(
              children: [
                Icon(Icons.store, color: kPrimaryColor, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  group.sellerName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                    color: kTextColor,
                  ),
                ),
              ],
            ),
          ),

          // Items List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: group.items.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, i) {
              final item = group.items[i];
              return CartItemWidget(item: item);
            },
          ),

          // Subtotal
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                ),
                Text(
                  '\$${group.subtotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Cart Item
class CartItemWidget extends StatelessWidget {
  final CartItem item;

  const CartItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.network(
              item.product.imageUrl,
              width: 60.w,
              height: 60.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.error, size: 40.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '\$${item.product.price.toStringAsFixed(2)} × ${item.quantity}',
                  style:
                      TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline, size: 20.sp),
                onPressed: () => cart.decreaseQuantity(item.product.id),
              ),
              Text('${item.quantity}',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.add_circle_outline, size: 20.sp),
                onPressed: () => cart.increaseQuantity(item.product.id),
              ),
              IconButton(
                icon:
                    Icon(Icons.delete_outline, color: Colors.red, size: 20.sp),
                onPressed: () => cart.removeItem(item.product.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
