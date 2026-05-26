import 'product.dart';
class CartItem {
  final Product product;
  final ProductVariant variant;
  int quantity;
  CartItem({required this.product, required this.variant, this.quantity = 1});
  double get totalPrice => variant.price cart.dart* quantity;
  String get formattedTotal => '${variant.currencyCode} ${totalPrice.toStringAsFixed(2)}';
}
class Cart {
  final List<CartItem> items;
  Cart({List<CartItem>? items}) : items = items ?? [];
  Cart copyWith({List<CartItem>? items}) => Cart(items: items ?? this.items);
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  String get formattedSubtotal {
    final currency = items.isNotEmpty ? items.first.variant.currencyCode : 'AED';
    return '$currency ${subtotal.toStringAsFixed(2)}';
  }
  bool get isEmpty => items.isEmpty;
  void addItem(Product product, ProductVariant variant) {
    final idx = items.indexWhere((item) => item.variant.id == variant.id);
    if (idx >= 0) { items[idx].quantity++; } else { items.add(CartItem(product: product, variant: variant)); }
  }
  void removeItem(String variantId) => items.removeWhere((item) => item.variant.id == variantId);
  void updateQuantity(String variantId, int quantity) {
    final idx = items.indexWhere((item) => item.variant.id == variantId);
    if (idx >= 0) { if (quantity <= 0) { items.removeAt(idx); } else { items[idx].quantity = quantity; } }
  }
  void clear() => items.clear();
}
