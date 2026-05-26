class ProductImage {
  final String src;
  final String? altText;
  ProductImage({required this.src, this.altText});
  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(src: json['url'] ?? json['src'] ?? '', altText: json['altText']);
  }
}
class ProductVariant {
  final String id;
  final String title;
  final double price;
  final String currencyCode;
  final bool availableForSale;
  final int? quantityAvailable;
  ProductVariant({required this.id, required this.title, required this.price, required this.currencyCode, required this.availableForSale, this.quantityAvailable});
  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    final priceV2 = json['priceV2'] ?? {};
    return ProductVariant(id: json['id'] ?? '', title: json['title'] ?? 'Default', price: double.tryParse(priceV2['amount']?.toString() ?? '0') ?? 0.0, currencyCode: priceV2['currencyCode'] ?? 'AED', availableForSale: json['availableForSale'] ?? true, quantityAvailable: json['quantityAvailable']);
  }
}
class Product {
  final String id, title, description, handle;
  final List<ProductImage> images;
  final List<ProductVariant> variants;
  final String? vendor, productType;
  final List<String> tags;
  Product({required this.id, required this.title, required this.description, required this.handle, required this.images, required this.variants, this.vendor, this.productType, this.tags = const []});
  String get imageUrl => images.isNotEmpty ? images.first.src : '';
  double get price => variants.isNotEmpty ? variants.first.price : 0.0;
  String get currencyCode => variants.isNotEmpty ? variants.first.currencyCode : 'AED';
  bool get availableForSale => variants.any((v) => v.availableForSale);
  String get formattedPrice => '$currencyCode ${price.toStringAsFixed(2)}';
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(id: json['id'] ?? '', title: json['title'] ?? '', description: json['description'] ?? '', handle: json['handle'] ?? '', images: ((json['images']?['edges'] as List?) ?? []).map((e) => ProductImage.fromJson(e['node'] ?? e)).toList(), variants: ((json['variants']?['edges'] as List?) ?? []).map((e) => ProductVariant.fromJson(e['node'] ?? e)).toList(), vendor: json['vendor'], productType: json['productType'], tags: List<String>.from(json['tags'] ?? []));
  }
}
class Collection {
  final String id, title, handle;
  final String? description, imageUrl;
  Collection({required this.id, required this.title, required this.handle, this.description, this.imageUrl});
  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(id: json['id'] ?? '', title: json['title'] ?? '', handle: json['handle'] ?? '', description: json['description'], imageUrl: json['image']?['url']);
  }
}
