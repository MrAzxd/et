import 'package:e/widgets/Bottom_Bar.dart';
import 'package:e/screens/admin/request_approval_screen.dart';
import 'package:e/screens/admin/rejected_requests_screen.dart';
import 'package:e/screens/auth/role_selection_screen.dart';
import 'package:e/screens/auth/customer_signup_screen.dart';
import 'package:e/screens/auth/seller_signup_screen.dart';
import 'package:e/screens/seller/request_screen.dart';
import 'package:e/services/auth_service.dart';
import 'package:e/utils/constants.dart';
import 'package:e/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final user = await _authService.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (user != null) {
          final userData = await _authService.getUserData(user.uid);

          if (userData != null) {
            if (userData['role'] == 'buyer') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BottomBar()),
              );
            } else if (userData['role'] == 'seller') {
              Navigator.pushReplacementNamed(context, RequestScreen.routeName);
            } else {
              Navigator.pushReplacementNamed(
                  context, RoleSelectionScreen.routeName);
            }
          } else {
            /// If no user data, go to role selection
            Navigator.pushReplacementNamed(
                context, RoleSelectionScreen.routeName);
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login failed: ${e.toString()}',
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
              padding: const EdgeInsets.all(kDefaultPadding),
              child: AnimationLimiter(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(kDefaultBorderRadius * 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(kDefaultPadding * 1.5),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 375),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(child: widget),
                          ),
                          children: [
                            // Logo
                            const Icon(
                              Icons.shopping_bag,
                              size: 80,
                              color: kPrimaryColor,
                            ),
                            const SizedBox(height: kSmallPadding),
                            Text(
                              kAppName,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .copyWith(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )
                                .animate()
                                .fade(duration: 500.ms)
                                .scale(delay: 500.ms),
                            const SizedBox(height: kLargePadding * 2),
                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email,
                                    color: kPrimaryColor),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      kDefaultBorderRadius),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      kDefaultBorderRadius),
                                  borderSide: BorderSide(
                                      color: kBorderColor.withOpacity(0.5)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      kDefaultBorderRadius),
                                  borderSide: const BorderSide(
                                      color: kPrimaryColor, width: 2),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.validateEmail,
                            ),
                            const SizedBox(height: kDefaultPadding),
                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock,
                                    color: kPrimaryColor),
                                suffixIcon: IconButton(
                                  icon: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      key: ValueKey<bool>(_obscurePassword),
                                      color: kTextColorSecondary,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      kDefaultBorderRadius),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      kDefaultBorderRadius),
                                  borderSide: BorderSide(
                                      color: kBorderColor.withOpacity(0.5)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      kDefaultBorderRadius),
                                  borderSide: const BorderSide(
                                      color: kPrimaryColor, width: 2),
                                ),
                              ),
                              obscureText: _obscurePassword,
                              validator: Validators.validatePassword,
                            ),
                            const SizedBox(height: kLargePadding),
                            // Login Button
                            _isLoading
                                ? const CircularProgressIndicator(
                                    color: kPrimaryColor)
                                : AnimatedScaleButton(
                                    child: Container(
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
                                          onPressed: _login,
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
                                              horizontal: 32,
                                            ),
                                          ),
                                          child: Text(
                                            'Login',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )),
                                    ),
                                  ),
                            const SizedBox(height: kDefaultPadding),
                            // Signup Links
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, CustomerSignupScreen.routeName);
                                  },
                                  child: Text(
                                    'Sign up as Customer',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: kPrimaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, SellerSignupScreen.routeName);
                                  },
                                  child: Text(
                                    'Sign up as Seller',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: kSecondaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            // Requests Link
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, RequestApprovalScreen.routeName);
                              },
                              child: Text(
                                'View Requests',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),


                            // Requests Link
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, RejectedRequestsScreen.routeName);
                              },
                              child: Text(
                                'Rejected Requests',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.w600,
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
