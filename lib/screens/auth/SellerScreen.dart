import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:e/utils/constants.dart';
import 'package:e/screens/seller/request_screen.dart';
import 'package:e/services/auth_service.dart';
import 'package:e/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  bool _isEditing = false;
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await _firestoreService.getUserData(user.uid);
        final existingRequest = await _firestoreService.getSellerRequest(user.uid);
        
        if (userData != null && existingRequest != null && mounted) {
          setState(() {
            _isEditing = true;
            shopNameController.text = userData['shopName'] ?? '';
            ownerNameController.text = userData['name'] ?? '';
            addressController.text = userData['shopAddress'] ?? '';
            cityController.text = userData['city'] ?? '';
            categoryController.text = userData['shopCategory'] ?? '';
            cnicController.text = userData['cnic'] ?? '';
            descriptionController.text = userData['shopDescription'] ?? '';
          });
        }
      }
    } catch (e) {
      // Handle error silently or show a message
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _submitShopInfo() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Save shop details to user document
          await _authService.updateUserShopDetails(
            user.uid,
            shopName: shopNameController.text.trim(),
            city: cityController.text.trim(),
            shopAddress: addressController.text.trim(),
            shopCategory: categoryController.text.trim(),
            cnic: cnicController.text.trim(),
            shopDescription: descriptionController.text.trim(),
          );

          // Check if user already has a request (for resubmission)
          final existingRequest = await _firestoreService.getSellerRequest(user.uid);
          if (existingRequest != null) {
            // Update existing request status to pending (resubmission)
            await _firestoreService.updateRequestStatus(user.uid, 'pending');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Shop information updated and resubmitted for admin approval"),
                ),
              );
            }
          } else {
            // Create new seller request
            await _firestoreService.createSellerRequest(user.uid);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Shop submitted for admin approval"),
                ),
              );
            }
          }

          if (mounted) {
            Navigator.pushReplacementNamed(context, RequestScreen.routeName);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to submit shop: ${e.toString()}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Shop Information' : 'Shop Information',
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
                          _isEditing ? 'UPDATE & RESUBMIT' : 'SUBMIT FOR APPROVAL',
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
          _isEditing ? 'Update Your Shop Details' : 'Seller Shop Details',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: kTextColor,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          _isEditing 
            ? 'Update your information and resubmit for admin approval'
            : 'Provide accurate information for admin verification',
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
