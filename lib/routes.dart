import 'package:e/models/product_model.dart';
import 'package:e/screens/admin/request_approval_screen.dart';
import 'package:e/screens/auth/login_screen.dart';
import 'package:e/screens/auth/role_selection_screen.dart';
import 'package:e/screens/auth/signup_screen.dart';
import 'package:e/screens/buyer/home_screen.dart';
import 'package:e/screens/buyer/product_detail_screen.dart';
import 'package:e/screens/buyer/product_list_screen.dart';
import 'package:e/screens/seller/Bottom/S_Bottom_bar.dart';
import 'package:e/screens/seller/Sellerprofile/Seller_profile.dart';
import 'package:e/screens/seller/product_upload_screen.dart';
import 'package:e/screens/seller/product_edit_screen.dart';
import 'package:e/screens/seller/request_screen.dart';
import 'package:e/screens/seller/seller_dashboard_screen.dart';
import 'package:e/screens/seller/shop_setup_screen.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case LoginScreen.routeName:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case SignupScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case RoleSelectionScreen.routeName:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
      case HomeScreen.routeName:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case ProductListScreen.routeName:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ProductListScreen(category: args),
          );
        }
        return _errorRoute();
      case ProductDetailScreen.routeName:
        if (args is ProductModel) {
          return MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: args),
          );
        }
        return _errorRoute();
      case RequestScreen.routeName:
        return MaterialPageRoute(builder: (_) => const RequestScreen());
      case ShopSetupScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ShopSetupScreen());
      case ProductUploadScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ProductUploadScreen());
      case SellerDashboardScreen.routeName:

        // here ak edit this for navigator to seller bottom bar
        // return MaterialPageRoute(builder: (_) => const SellerDashboardScreen());
        return MaterialPageRoute(builder: (_) => const SellerBottomBar());
      case RequestApprovalScreen.routeName:
        return MaterialPageRoute(builder: (_) => const RequestApprovalScreen());
      case ProductEditScreen.routeName:
        if (args is ProductModel) {
          return MaterialPageRoute(
            builder: (_) => ProductEditScreen(product: args),
          );
        }
        return _errorRoute();
      case SellerProfileScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SellerProfileScreen());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Invalid route'),
        ),
      ),
    );
  }
}
