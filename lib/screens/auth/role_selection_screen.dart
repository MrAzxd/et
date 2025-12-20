import 'package:e/screens/buyer/home_screen.dart';
import 'package:e/screens/seller/request_screen.dart';
import 'package:e/services/auth_service.dart';
import 'package:e/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoleSelectionScreen extends StatefulWidget {
  static const String routeName = '/role-selection';

  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _selectedRole;

  Future<void> _selectRole(String role) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _authService.updateUserRole(user.uid, role);
        if (role == 'buyer') {
          Navigator.pushReplacementNamed(context, HomeScreen.routeName);
        } else if (role == 'seller') {
          Navigator.pushReplacementNamed(context, RequestScreen.routeName);
        }
      } else {
        throw Exception('No user logged in');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to select role: ${e.toString()}',
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(kDefaultPadding.w),
              child: AnimationLimiter(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      // Logo
                      Icon(
                        Icons.shopping_bag,
                        size: 80.sp,
                        color: kPrimaryColor,
                      ),
                      SizedBox(height: kSmallPadding.h),
                      Text(
                        kAppName,
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge!
                            .copyWith(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: kLargePadding.h),

                      // Title
                      Text(
                        'Choose Your Role',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              color: kTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: kSmallPadding.h),
                      Text(
                        'Select how you want to experience our platform',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(
                              color: kTextColorSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: (kLargePadding * 2).h),

                      // Role Selection Cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildRoleCard(
                            context,
                            role: 'Buyer',
                            note: 'Shop the best products with ease',
                            icon: Icons.shop,
                            isSelected: _selectedRole == 'buyer',
                            onTap: () {
                              setState(() {
                                _selectedRole = 'buyer';
                              });
                              _selectRole('buyer');
                            },
                          ),
                          SizedBox(width: kDefaultPadding.w),
                          _buildRoleCard(
                            context,
                            role: 'Seller',
                            note: 'Sell your products and grow your business',
                            icon: Icons.store,
                            isSelected: _selectedRole == 'seller',
                            onTap: () {
                              setState(() {
                                _selectedRole = 'seller';
                              });
                              _selectRole('seller');
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: kLargePadding.h),

                      if (_isLoading)
                        const CircularProgressIndicator(
                          color: kPrimaryColor,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String role,
    required String note,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedScaleButton(
      child: GestureDetector(
        onTap: _isLoading ? null : onTap,
        child: Card(
          elevation: isSelected ? 12 : 6,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular((kDefaultBorderRadius * 1.5).r),
            side: BorderSide(
              color: isSelected
                  ? kPrimaryColor
                  : kBorderColor.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 160.w,
            padding: EdgeInsets.all(kDefaultPadding.w),
            decoration: BoxDecoration(
              color:
                  isSelected ? kPrimaryColor.withOpacity(0.1) : Colors.white,
              borderRadius:
                  BorderRadius.circular((kDefaultBorderRadius * 1.5).r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 50.sp,
                  color:
                      isSelected ? kPrimaryColor : kTextColorSecondary,
                ),
                SizedBox(height: kSmallPadding.h),
                Text(
                  role,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(
                        color:
                            isSelected ? kPrimaryColor : kTextColor,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                ),
                SizedBox(height: (kSmallPadding / 2).h),
                Text(
                  note,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(
                        color: kTextColorSecondary,
                        fontSize: 12.sp,
                      ),
                  textAlign: TextAlign.center,
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
