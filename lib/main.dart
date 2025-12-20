import 'package:e/screens/auth/SellerScreen.dart';
import 'package:e/screens/auth/role_selection_screen.dart';
import 'package:e/screens/buyer/home_screen.dart';
import 'package:e/screens/seller/Bottom/S_Bottom_bar.dart';
import 'package:e/test.dart';
import 'package:e/widgets/Bottom_Bar.dart';
import 'package:e/provider/wishlist_provider.dart';
import 'package:e/routes.dart';
import 'package:e/screens/auth/login_screen.dart';
import 'package:e/provider/cart_provider.dart';
import 'package:e/provider/orderprovider.dart';
import 'package:e/screens/seller/request_screen.dart';
import 'package:e/screens/seller/seller_dashboard_screen.dart';
import 'package:e/services/auth_service.dart';
import 'package:e/utils/constants.dart';
import 'package:e/utils/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => OrdersProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => WishlistProvider(),
    )
  ], child: const EcommerceApp()));
}

class EcommerceApp extends StatelessWidget {
  const EcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(411, 890),
        minTextAdapt: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Fresh Cart',
            theme: AppTheme.theme,
            home: SplashScreen(),
            // home: SellerShopInfoScreen(),
            // home: ContainerColumn(),
            onGenerateRoute: RouteGenerator.generateRoute,
          );
        });
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return;
      }

      final authService = AuthService();
      final userData = await authService.getUserData(user.uid);

      if (!mounted) return; // check again before navigating

      if (userData != null) {
        if (userData['role'] == 'buyer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomBar()),
          );
        } else if (userData['role'] == 'seller') {
          if (userData['shopId'] != null && userData['shopId'].isNotEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  // builder: (context) => const SellerDashboardScreen()),
                  builder: (context) => const SellerBottomBar()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RequestScreen()),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      debugPrint("Auth check failed: $e");
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: kPrimaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              'E-commerce App',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge!
                  .copyWith(color: Colors.white),
            ).animate().fade(duration: 500.ms).scale(delay: 500.ms)
            // .moveY(begin: 50, end: 0, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
