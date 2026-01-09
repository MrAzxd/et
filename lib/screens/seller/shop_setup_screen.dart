import 'package:e/screens/seller/seller_dashboard_screen.dart';
import 'package:e/screens/auth/login_screen.dart';
import 'package:e/services/firestore_service.dart';
import 'package:e/utils/constants.dart';
import 'package:e/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ShopSetupScreen extends StatefulWidget {
  static const String routeName = '/shop-setup';

  const ShopSetupScreen({super.key});

  @override
  State<ShopSetupScreen> createState() => _ShopSetupScreenState();
}

class _ShopSetupScreenState extends State<ShopSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingShopName();
  }

  Future<void> _loadExistingShopName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await _firestoreService.getUserData(user.uid);
        if (userData != null) {
          setState(() {
            _nameController.text = userData['shopName'] ?? '';
            _descriptionController.text = userData['shopDescription'] ?? '';
          });
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createShop() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final shopId = await _firestoreService.createShop(
            sellerId: user.uid,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
          );
          await _firestoreService.updateUserShopId(user.uid, shopId );
          Navigator.pushReplacementNamed(
              context, SellerDashboardScreen.routeName);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Shop created successfully!'),
              backgroundColor: kPrimaryColor,
            ),
          );
        } else {
          throw Exception('No user logged in');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create shop: ${e.toString()}',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Set Up Your Shop',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.pushReplacementNamed(context, LoginScreen.routeName);
              }
            });
          },
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        // Logo
                        const Center(
                          child: Icon(
                            Icons.store,
                            size: 80,
                            color: kPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: kSmallPadding),
                        // Title
                        Center(
                          child: Text(
                            'Create Your Shop',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .copyWith(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(height: kSmallPadding),
                        // Subtitle
                        Center(
                          child: Text(
                            'Set up your store to start selling',
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: kTextColorSecondary,
                                    ),
                          ),
                        ),
                        const SizedBox(height: kLargePadding),
                        // Shop Name Field
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Shop Name',
                            prefixIcon: const Icon(Icons.storefront,
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
                          validator: (value) =>
                              Validators.validateName(value, 'shop name'),
                        ),
                        const SizedBox(height: kDefaultPadding),
                        // Description Field
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Shop Description',
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
                        // Create Shop Button
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
                                    onPressed: _createShop,
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
                                      'Create Shop',
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
