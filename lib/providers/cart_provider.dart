import 'package:flutter/foundation.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../services/shopify_service.dart';

class CartProvider extends ChangeNotifier {
  final Cart _cart = Cart();
  Cart get cart => _cart;
  int get itemCount => _cart.itemCount;
  double get subtotal => _cart.subtotal;
  String get formattedSubtotal => _cart.formattedSubtotal;
  bool get isEmpty => _cart.isEmpty;
  List<CartItem> get items => _cart.items;

  void addToCart(Product product, ProductVariant variant) {
    _cart.addItem(product, variant);
    notifyListeners();
  }

  void removeFromCart(String variantId) {
    _cart.removeItem(variantId);
    notifyListeners();
  }

  void updateQuantity(String variantId, int quantity) {
    _cart.updateQuantity(variantId, quantity);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Future<String?> checkout() async {
    if (_cart.isEmpty) return null;
    final lineItems = _cart.items
        .map((item) => {'variantId': item.variant.id, 'quantity': item.quantity})
        .toList();
    return await ShopifyService.createCheckout(lineItems);
  }
}
