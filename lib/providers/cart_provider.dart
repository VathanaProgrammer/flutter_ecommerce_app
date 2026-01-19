import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/cart.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  // ✅ FIX: Use finalPrice instead of price
  double get totalPrice => product.finalPrice * quantity;

  // Add this to track original price before discount
  double get originalTotalPrice => product.price * quantity;

  // Add this to track discount amount
  double get discountAmount => originalTotalPrice - totalPrice;
}

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {}; // productId -> CartItem

  // Get all cart items as a list
  List<CartItem> get items => _items.values.toList();

  // Get total number of items (sum of all quantities)
  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  // ✅ Calculate subtotal BEFORE discount
  double get subtotalBeforeDiscount {
    return _items.values.fold(
      0.0,
      (sum, item) => sum + item.originalTotalPrice,
    );
  }

  // ✅ Calculate total discount amount
  double get discountAmount {
    return _items.values.fold(0.0, (sum, item) => sum + item.discountAmount);
  }

  // ✅ Calculate subtotal AFTER discount
  double get subtotal {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get shippingCharge => 1.50;

  // Calculate total (no tax)
  double get total => subtotal + (shippingCharge ?? 0);

  // Add product to cart
  void add(Product product) {
    if (_items.containsKey(product.id)) {
      // Increment quantity if product already exists
      _items[product.id] = CartItem(
        product: product,
        quantity: _items[product.id]!.quantity + 1,
      );
    } else {
      // Add new product
      _items[product.id] = CartItem(product: product, quantity: 1);
    }
    notifyListeners();
  }

  // Remove product from cart
  void remove(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Increment product quantity
  void increment(int productId) {
    if (_items.containsKey(productId)) {
      final item = _items[productId]!;
      _items[productId] = CartItem(
        product: item.product,
        quantity: item.quantity + 1,
      );
      notifyListeners();
    }
  }

  // Decrement product quantity
  void decrement(int productId) {
    if (_items.containsKey(productId)) {
      final item = _items[productId]!;
      if (item.quantity > 1) {
        _items[productId] = CartItem(
          product: item.product,
          quantity: item.quantity - 1,
        );
        notifyListeners();
      } else {
        // Remove item if quantity would be 0
        remove(productId);
      }
    }
  }

  // Clear all items from cart
  void clear() {
    _items.clear();
    notifyListeners();
  }

  Future<Map<String, dynamic>> checkoutCash({
    required Map<String, dynamic> payloadSnapshot,
  }) async {
    // Call the service function
    final result = await CartService.checkoutCash(
      payloadSnapshot: payloadSnapshot,
    );

    // Simply return the Map from the service
    return result;
  }
}
