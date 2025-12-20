import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:e/utils/constants.dart';

class SellerShopInfoScreen extends StatefulWidget {
  static const String routeName = '/seller-shop-info';

  const SellerShopInfoScreen({super.key});

  @override
  State<SellerShopInfoScreen> createState() => _SellerShopInfoScreenState();
}

class _SellerShopInfoScreenState extends State<SellerShopInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final shopNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final categoryController = TextEditingController();
  final cnicController = TextEditingController();
  final descriptionController = TextEditingController();

  bool _isLoading = false;

  void _submitShopInfo() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // 🔥 Firestore save logic (status = pending) will go here

      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Shop submitted for admin approval"),
          ),
        );

        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shop Information',
          style: TextStyle(fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(kDefaultPadding.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _titleSection(),

              SizedBox(height: 25.h),

              _inputField(
                controller: shopNameController,
                label: 'Shop Name',
                icon: Icons.store,
              ),

              _inputField(
                controller: ownerNameController,
                label: 'Owner Name',
                icon: Icons.person,
              ),

              _inputField(
                controller: addressController,
                label: 'Shop Address',
                icon: Icons.location_on,
              ),

              _inputField(
                controller: cityController,
                label: 'City',
                icon: Icons.location_city,
              ),

              _inputField(
                controller: categoryController,
                label: 'Shop Category',
                icon: Icons.category,
              ),

              _inputField(
                controller: cnicController,
                label: 'CNIC Number',
                icon: Icons.badge,
                keyboardType: TextInputType.number,
              ),

              _inputField(
                controller: descriptionController,
                label: 'Shop Description',
                icon: Icons.description,
                maxLines: 3,
              ),

              SizedBox(height: 30.h),

              SizedBox(
                width: double.infinity,
                height: 61.h,
                child: 
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitShopInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'SUBMIT FOR APPROVAL',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seller Shop Details',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: kTextColor,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Provide accurate information for admin verification',
          style: TextStyle(
            fontSize: 14.sp,
            color: kTextColorSecondary,
          ),
        ),
      ],
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) =>
            value == null || value.isEmpty ? 'Required field' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ),
    );
  }
}
