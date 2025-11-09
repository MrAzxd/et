import 'package:e/models/product_model.dart';
import 'package:flutter/foundation.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> items = [];

  // Grouped carts by sellerId
  Map<String, CartGroup> get groupedCarts {
    final Map<String, CartGroup> groups = {};

    for (var item in items) {
      final sellerId = item.product.sellerId;
      final sellerName = item.product.sellerName;

      if (!groups.containsKey(sellerId)) {
        groups[sellerId] = CartGroup(
          sellerId: sellerId,
          sellerName: sellerName,
          items: [],
          subtotal: 0.0,
        );
      }

      groups[sellerId]!.items.add(item);
      groups[sellerId]!.subtotal += item.product.price * item.quantity;
    }

    return groups;
  }

  // Grand total of all items
  double get grandTotal {
    double total = 0.0;
    for (var group in groupedCarts.values) {
      total += group.subtotal;
    }
    return total;
  }

  int get totalItemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Add item (no seller restriction anymore)
  void addItem(ProductModel product, int quantity) {
    bool found = false;
    for (int i = 0; i < items.length; i++) {
      if (items[i].product.id == product.id) {
        items[i].quantity += quantity;
        found = true;
        break;
      }
    }
    if (!found) {
      items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    for (var item in items) {
      if (item.product.id == productId) {
        item.quantity++;
        notifyListeners();
        return;
      }
    }
  }

  void decreaseQuantity(String productId) {
    for (var item in items) {
      if (item.product.id == productId && item.quantity > 1) {
        item.quantity--;
        notifyListeners();
        return;
      }
    }
  }

  void removeItem(String productId) {
    items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    items.clear();
    notifyListeners();
  }
}

// Helper class to represent a shop group
class CartGroup {
  final String sellerId;
  final String sellerName;
  final List<CartItem> items;
  double subtotal;

  CartGroup({
    required this.sellerId,
    required this.sellerName,
    required this.items,
    required this.subtotal,
  });
}

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}
