import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/cart.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  double get totalPrice => product.finalPrice * quantity;
  double get originalTotalPrice => product.price * quantity;
  double get discountAmount => originalTotalPrice - totalPrice;
}

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get subtotalBeforeDiscount {
    return _items.values.fold(
      0.0,
      (sum, item) => sum + item.originalTotalPrice,
    );
  }

  double get discountAmount {
    return _items.values.fold(0.0, (sum, item) => sum + item.discountAmount);
  }

  double get subtotal {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get shippingCharge => 1.50;
  double get total => subtotal + shippingCharge;

  void add(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id] = CartItem(
        product: product,
        quantity: _items[product.id]!.quantity + 1,
      );
    } else {
      _items[product.id] = CartItem(product: product, quantity: 1);
    }
    notifyListeners();
  }

  void remove(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

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
        remove(productId);
      }
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  Future<Map<String, dynamic>> checkoutCash({
    required Map<String, dynamic> payloadSnapshot,
  }) async {
    return await CartService.checkoutCash(payloadSnapshot: payloadSnapshot);
  }
}
