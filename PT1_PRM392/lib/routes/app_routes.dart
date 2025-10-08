import 'package:flutter/material.dart';
import '../product_list_page.dart'; // Import file cũ của bạn
import '../simple_login_screen.dart'; // Import simple login screen

class AppRoutes {
  static const String login = '/login';
  static const String productList = '/products';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String productManagement = '/admin/products';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const SimpleLoginScreen());

      case productManagement:
        return MaterialPageRoute(builder: (_) => const ProductListPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
