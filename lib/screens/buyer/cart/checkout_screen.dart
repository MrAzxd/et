import 'package:e/provider/cart_provider.dart';
import 'package:e/screens/buyer/cart/payment.dart';
import 'package:e/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CheckoutScreen extends StatefulWidget {
  static const String routeName = '/checkout';

  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final groupedCarts = cart.groupedCarts;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: AnimationLimiter(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(kDefaultPadding.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  // Shipping Info
                  Text(
                    'Shipping Information',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: kTextColor,
                        ),
                  ),
                  SizedBox(height: kDefaultPadding.h),
                  _buildTextField(_nameController, 'Full Name',
                      validator: (v) => v!.isEmpty ? 'Required' : null),
                  SizedBox(height: kSmallPadding.h),
                  _buildTextField(_emailController, 'Email',
                      keyboardType: TextInputType.emailAddress, validator: (v) {
                    if (v!.isEmpty) return 'Required';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  }),
                  SizedBox(height: kSmallPadding.h),
                  _buildTextField(_addressController, 'Address',
                      validator: (v) => v!.isEmpty ? 'Required' : null),
                  SizedBox(height: kSmallPadding.h),
                  _buildTextField(_cityController, 'City',
                      validator: (v) => v!.isEmpty ? 'Required' : null),
                  SizedBox(height: kSmallPadding.h),
                  _buildTextField(_zipController, 'ZIP Code',
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null),

                  SizedBox(height: kLargePadding.h),

                  // Order Summary by Shop
                  Text(
                    'Order Summary',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: kTextColor,
                        ),
                  ),
                  SizedBox(height: kDefaultPadding.h),

                  ...groupedCarts.entries.map((entry) {
                    final group = entry.value;
                    return Card(
                      margin: EdgeInsets.only(bottom: kSmallPadding.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                      child: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.store,
                                    size: 18.sp, color: kPrimaryColor),
                                SizedBox(width: 6.w),
                                Text(
                                  group.sellerName,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            ...group.items
                                .map((item) => Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 4.h),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                              child: Text(item.product.name,
                                                  style: TextStyle(
                                                      fontSize: 13.sp))),
                                          Text(
                                              '${item.quantity} × \$${item.product.price.toStringAsFixed(2)}'),
                                        ],
                                      ),
                                    ))
                                .toList(),
                            Divider(height: 16.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Subtotal',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)),
                                Text('\$${group.subtotal.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: kPrimaryColor)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  SizedBox(height: kLargePadding.h),

                  // Grand Total
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Grand Total',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.sp),
                        ),
                        Text(
                          '\$${cart.grandTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                              color: kPrimaryColor),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: kLargePadding.h),

                  // Proceed Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => PaymentScreen(
                                shippingName: _nameController.text,
                                shippingEmail: _emailController.text,
                                shippingAddress: _addressController.text,
                                shippingCity: _cityController.text,
                                shippingZip: _zipController.text,
                                groupedCarts: groupedCarts, // Pass grouped data
                              ),
                            ),
                          );
                        }
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
                        'Proceed to Payment',
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
      validator: validator,
    );
  }
}
