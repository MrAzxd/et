import 'dart:io';
import 'package:e/screens/seller/seller_dashboard_screen.dart';
import 'package:e/services/firestore_service.dart';
import 'package:e/services/storage_service.dart';
import 'package:e/utils/constants.dart';
import 'package:e/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ProductUploadScreen extends StatefulWidget {
  static const String routeName = '/product-upload';

  const ProductUploadScreen({super.key});

  @override
  State<ProductUploadScreen> createState() => _ProductUploadScreenState();
}

class _ProductUploadScreenState extends State<ProductUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  String? _selectedCategory;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProduct() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('No user logged in');
        }
        final userData = await _firestoreService.getUserData(user.uid);
        final shopId = userData?['shopId'];
        if (shopId == null) {
          throw Exception('No shop found for this seller');
        }

        // Load shop name
        final shop = await _firestoreService.getShop(shopId);
        if (shop == null) {
          throw Exception('Shop data not found');
        }
        final shopName = shop.name;

        final imageUrl =
            await _storageService.uploadProductImage(_imageFile!, shopId);
        await _firestoreService.createProduct(
          shopId: shopId,
          name: _nameController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          category: _selectedCategory!,
          description: _descriptionController.text.trim(),
          imageUrl: imageUrl,
          sellerId: user.uid,
          sellerName: shopName, // Add shop name here
        );

        Navigator.pushNamed(context, SellerDashboardScreen.routeName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Product uploaded successfully!'),
            backgroundColor: kPrimaryColor,
          ),
        );
      } catch (e) {
        print('Upload error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to upload product: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: kErrorColor,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image'),
          backgroundColor: kErrorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Upload Product',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: AnimationLimiter(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kDefaultBorderRadius * 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding * 1.5),
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
                        // Title
                        Text(
                          'Add New Product',
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
                          'Showcase your products to buyers',
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: kTextColorSecondary,
                                  ),
                        ),
                        const SizedBox(height: kLargePadding),
                        // Image Picker
                        Center(
                          child: AnimatedScaleButton(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(color: kBorderColor),
                                  borderRadius: BorderRadius.circular(
                                      kDefaultBorderRadius),
                                  boxShadow: [
                                    BoxShadow(
                                      color: kPrimaryColor.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  image: _imageFile != null
                                      ? DecorationImage(
                                          image: FileImage(_imageFile!),
                                          fit: BoxFit.cover,
                                        )
                                      : const DecorationImage(
                                          image: NetworkImage(kDefaultImageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                child: _imageFile == null
                                    ? const Center(
                                        child: Icon(
                                          Icons.add_a_photo,
                                          color: kPrimaryColor,
                                          size: 40,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: kLargePadding),
                        // Product Name Field
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Product Name',
                            prefixIcon:
                                const Icon(Icons.label, color: kPrimaryColor),
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
                          validator: (value) =>
                              Validators.validateName(value, 'product name'),
                        ),
                        const SizedBox(height: kDefaultPadding),
                        // Price Field
                        TextFormField(
                          controller: _priceController,
                          decoration: InputDecoration(
                            labelText: 'Price',
                            prefixIcon: const Icon(Icons.attach_money,
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
                          keyboardType: TextInputType.number,
                          validator: Validators.validatePrice,
                        ),
                        const SizedBox(height: kDefaultPadding),
                        // Category Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            prefixIcon: const Icon(Icons.category,
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
                          items: kProductCategories
                              .map((category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                          validator: Validators.validateCategory,
                        ),
                        const SizedBox(height: kDefaultPadding),
                        // Description Field
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            prefixIcon: const Icon(Icons.description,
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
                          maxLines: 4,
                          validator: Validators.validateDescription,
                        ),
                        const SizedBox(height: kLargePadding),
                        // Upload Button
                        _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: kPrimaryColor),
                              )
                            : AnimatedScaleButton(
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
                                    onPressed: _uploadProduct,
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
                                      'Upload Product',
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
