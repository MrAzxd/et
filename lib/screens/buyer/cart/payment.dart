import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e/provider/cart_provider.dart';
import 'package:e/screens/buyer/home_screen.dart';
import 'package:e/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentScreen extends StatefulWidget {
  static const String routeName = '/payment';

  final String shippingName;
  final String shippingEmail;
  final String shippingAddress;
  final String shippingCity;
  final String shippingZip;
  final Map<String, CartGroup> groupedCarts; // Grouped by sellerId

  const PaymentScreen({
    super.key,
    required this.shippingName,
    required this.shippingEmail,
    required this.shippingAddress,
    required this.shippingCity,
    required this.shippingZip,
    required this.groupedCarts,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedPaymentMethod = 'cash_on_delivery';

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Validation helpers
  String? _validateCardNumber(String? v) =>
      v!.length != 16 ? '16 digits required' : null;
  String? _validateExpiry(String? v) =>
      !RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(v!) ? 'MM/YY' : null;
  String? _validateCVV(String? v) =>
      v!.length < 3 || v.length > 4 ? '3–4 digits' : null;

  // Save N orders (one per shop)
  Future<void> _placeMultipleOrders(CartProvider cart) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('Please log in', Colors.red);
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final ordersToCreate = <Map<String, dynamic>>[];

      for (final group in widget.groupedCarts.values) {
        final orderData = {
          'userId': user.uid,
          'userName': user.displayName ?? widget.shippingName,
          'userEmail': user.email ?? widget.shippingEmail,
          'sellerId': group.sellerId,
          'sellerName': group.sellerName,
          'shippingDetails': {
            'name': widget.shippingName,
            'email': widget.shippingEmail,
            'address': widget.shippingAddress,
            'city': widget.shippingCity,
            'zip': widget.shippingZip,
          },
          'items': group.items
              .map((item) => {
                    'productId': item.product.id,
                    'productName': item.product.name,
                    'price': item.product.price,
                    'quantity': item.quantity,
                    'imageUrl': item.product.imageUrl,
                  })
              .toList(),
          'totalAmount': group.subtotal,
          'status': 'Pending', // Matches OrdersProvider
          'createdAt': Timestamp.now(),
        };
        ordersToCreate.add(orderData);
      }

      // Save all orders
      final batch = FirebaseFirestore.instance.batch();
      for (final order in ordersToCreate) {
        final ref = FirebaseFirestore.instance.collection('orders').doc();
        batch.set(ref, order);
      }
      await batch.commit();

      // Only clear cart after success
      cart.clearCart();

      _showSnackBar('Success! ${widget.groupedCarts.length} orders placed.',
          kPrimaryColor);
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: bgColor,
          duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final totalShops = widget.groupedCarts.length;

    return SafeArea(
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
            title: const Text('Payment'),
            backgroundColor: kPrimaryColor,
            elevation: 0),
        body: AnimationLimiter(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(kDefaultPadding.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (w) => SlideAnimation(
                    verticalOffset: 50, child: FadeInAnimation(child: w)),
                children: [
                  // Payment Method
                  _buildSectionTitle('Select Payment Method'),
                  _buildRadioTile('Credit Card', 'credit_card'),
                  _buildRadioTile('Cash on Delivery', 'cash_on_delivery'),

                  // Credit Card Form (Conditional)
                  if (_selectedPaymentMethod == 'credit_card') ...[
                    SizedBox(height: kDefaultPadding.h),
                    _buildSectionTitle('Card Details'),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(_nameController, 'Name on Card',
                              validator: (v) => v!.isEmpty ? 'Required' : null),
                          SizedBox(height: kSmallPadding.h),
                          _buildTextField(_cardNumberController, 'Card Number',
                              keyboardType: TextInputType.number,
                              maxLength: 16,
                              validator: _validateCardNumber),
                          SizedBox(height: kSmallPadding.h),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildTextField(
                                      _expiryController, 'Expiry (MM/YY)',
                                      validator: _validateExpiry)),
                              SizedBox(width: kDefaultPadding.w),
                              Expanded(
                                  child: _buildTextField(_cvvController, 'CVV',
                                      keyboardType: TextInputType.number,
                                      maxLength: 4,
                                      validator: _validateCVV)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: kLargePadding.h),

                  // Order Summary
                  _buildSectionTitle('Order Summary ($totalShops Shops)'),
                  ...widget.groupedCarts.values
                      .map((group) => _buildShopSummaryCard(group))
                      .toList(),

                  SizedBox(height: kLargePadding.h),

                  // Grand Total
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Grand Total',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17.sp)),
                        Text('\$${cart.grandTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                                color: kPrimaryColor)),
                      ],
                    ),
                  ),

                  SizedBox(height: kLargePadding.h),

                  // Pay / Place Order Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_selectedPaymentMethod == 'credit_card') {
                          if (_formKey.currentState!.validate()) {
                            _showSnackBar('Payment processed!', kPrimaryColor);
                            cart.clearCart();
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/home', (route) => false);
                          }
                        } else {
                          await _placeMultipleOrders(cart);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(kDefaultBorderRadius)),
                      ),
                      child: Text(
                        _selectedPaymentMethod == 'credit_card'
                            ? 'Pay Now'
                            : 'Place $totalShops Orders',
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: kDefaultPadding.h),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontWeight: FontWeight.bold, color: kTextColor)),
    );
  }

  Widget _buildRadioTile(String title, String value) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 15.sp)),
      leading: Radio<String>(
        value: value,
        groupValue: _selectedPaymentMethod,
        onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
        activeColor: kPrimaryColor,
      ),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
      validator: validator,
    );
  }

  Widget _buildShopSummaryCard(CartGroup group) {
    return Card(
      margin: EdgeInsets.only(bottom: kSmallPadding.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.store, size: 18.sp, color: kPrimaryColor),
              SizedBox(width: 6.w),
              Text(group.sellerName,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp))
            ]),
            SizedBox(height: 8.h),
            ...group.items.map((item) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(item.product.name,
                              style: TextStyle(fontSize: 13.sp))),
                      Text(
                          '${item.quantity} × \$${item.product.price.toStringAsFixed(2)}'),
                    ],
                  ),
                )),
            Divider(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('\$${group.subtotal.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: kPrimaryColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
