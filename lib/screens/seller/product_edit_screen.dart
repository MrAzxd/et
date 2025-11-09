import 'dart:io';
import 'package:e/models/product_model.dart';
import 'package:e/screens/seller/seller_dashboard_screen.dart';
import 'package:e/services/firestore_service.dart';
import 'package:e/services/storage_service.dart';
import 'package:e/utils/constants.dart';
import 'package:e/utils/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ProductEditScreen extends StatefulWidget {
  static const String routeName = '/product-edit';
  final ProductModel product;

  const ProductEditScreen({super.key, required this.product});

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
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
  void initState() {
    super.initState();
    // Pre-populate fields with product data
    _nameController.text = widget.product.name;
    _priceController.text = widget.product.price.toString();
    _descriptionController.text = widget.product.description;
    _selectedCategory = widget.product.category;
  }

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

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('No user logged in');
        }
        String? imageUrl = widget.product.imageUrl;
        if (_imageFile != null) {
          imageUrl = await _storageService.uploadProductImage(
              _imageFile!, widget.product.shopId);
        }
        await _firestoreService.updateProduct(
          productId: widget.product.id,
          shopId: widget.product.shopId,
          name: _nameController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          category: _selectedCategory!,
          description: _descriptionController.text.trim(),
          imageUrl: imageUrl,
          sellerId: user.uid, // Add sellerId
        );
        Navigator.pushNamed(
            context, SellerDashboardScreen.routeName); // Changed to pushNamed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Product updated successfully!'),
            backgroundColor: kPrimaryColor,
          ),
        );
      } catch (e) {
        print('Update error: $e'); // Add debug logging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update product: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: kErrorColor,
          ),
        );
        print(' >>>>>>>>>$e \n\n\n');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteProduct() async {
    setState(() {
      _isLoading = true;
    });
    try {
      print(
          'Deleting product: ${widget.product.id}, shop: ${widget.product.shopId}'); // Add debug logging
      await _firestoreService.deleteProduct(
          widget.product.id, widget.product.shopId);
      Navigator.pushNamed(
          context, SellerDashboardScreen.routeName); // Changed to pushNamed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Product deleted successfully!'),
          backgroundColor: kPrimaryColor,
        ),
      );
    } catch (e) {
      print('Delete error: $e'); // Add debug logging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete product: ${e.toString()}',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Edit Product',
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
                          'Edit Your Product',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                color: kTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: kSmallPadding),
                        // Subtitle
                        Text(
                          'Update or delete your product details',
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
                                      : DecorationImage(
                                          image: NetworkImage(
                                              widget.product.imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                child: _imageFile == null &&
                                        widget.product.imageUrl.isEmpty
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
                        // Update and Delete Buttons
                        _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: kPrimaryColor),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: AnimatedScaleButton(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              kPrimaryColor,
                                              kPrimaryColor.withOpacity(0.8),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              kDefaultBorderRadius),
                                        ),
                                        child: ElevatedButton(
                                          onPressed: _updateProduct,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      kDefaultBorderRadius),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                              horizontal: 16,
                                            ),
                                          ),
                                          child: const Text(
                                            'Update Product',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  Expanded(
                                    child: AnimatedScaleButton(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              kErrorColor,
                                              kErrorColor.withOpacity(0.8),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              kDefaultBorderRadius),
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                    'Delete Product'),
                                                content: const Text(
                                                  'Are you sure you want to delete this product? This action cannot be undone.',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                          color: kPrimaryColor),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      _deleteProduct();
                                                    },
                                                    child: const Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                          color: kErrorColor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      kDefaultBorderRadius),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                              horizontal: 16,
                                            ),
                                          ),
                                          child: const Text(
                                            'Delete Product',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
