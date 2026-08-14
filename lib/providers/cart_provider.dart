import 'package:flutter/material.dart';
import '../core/services/cart_service.dart';
import '../models/cart_model.dart';

class CartProvider extends ChangeNotifier {
  final _cartService = CartService();

  CartModel cart = CartModel.empty();
  bool isLoading = false;
  String? errorMessage;

  int get itemCount => cart.items.fold(0, (sum, item) => sum + item.quantity);

  Future<void> fetchCart() async {
    isLoading = true;
    notifyListeners();
    try {
      cart = await _cartService.getMyCart();
    } catch (_) {
      errorMessage = "Failed to load cart";
    }
    isLoading = false;
    notifyListeners();
  }

  /// Primary method for adding items using named parameters
  Future<bool> addItem({required int productId, required int quantity}) async {
    try {
      cart = await _cartService.addItem(productId: productId, quantity: quantity);
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = "Failed to add item";
      notifyListeners();
      return false;
    }
  }

  /// Helper alias to handle dynamic/string IDs seamlessly from UI components
  Future<bool> addToCart(dynamic productId, [int quantity = 1]) {
    final int parsedId = productId is int ? productId : int.parse(productId.toString());
    return addItem(productId: parsedId, quantity: quantity);
  }

  Future<void> updateItem({required int itemId, required int quantity}) async {
    try {
      cart = await _cartService.updateItem(itemId: itemId, quantity: quantity);
      notifyListeners();
    } catch (_) {
      errorMessage = "Failed to update item";
      notifyListeners();
    }
  }

  Future<void> removeItem(int itemId) async {
    try {
      cart = await _cartService.removeItem(itemId);
      notifyListeners();
    } catch (_) {
      errorMessage = "Failed to remove item";
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      await _cartService.clearCart();
      cart = CartModel.empty();
      notifyListeners();
    } catch (_) {
      errorMessage = "Failed to clear cart";
      notifyListeners();
    }
  }
}