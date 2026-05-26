import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../services/shopify_service.dart';
import '../widgets/product_card.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}
class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Collection> _collections = [];
  Collection? _selectedCollection;
  List<Product> _products = [];
  bool _loadingCollections = true;
  bool _loadingProducts = false;
  String? _error;
  @override
  void initState() { super.initState(); _loadCollections(); }
  Future<void> _loadCollections() async {
    setState(() { _loadingCollections = true; _error = null; });
    try {
      final collections = await ShopifyService.fetchCollections(limit: 20);
      if (mounted) {
        setState(() { _collections = collections; _loadingCollections = false; });
        if (collections.isNotEmpty) _selectCollection(collections.first);
      }
    } catch (e) { if (mounted) setState(() { _error = e.toString(); _loadingCollections = false; }); }
  }
  Future<void> _selectCollection(Collection collection) async {
    setState(() { _selectedCollection = collection; _loadingProducts = true; _products = []; });
    try {
      final products = await ShopifyService.fetchProducts(collectionHandle: collection.handle, limit: 20);
      if (mounted) setState(() { _products = products; _loadingProducts = false; });
    } catch (e) { if (mounted) setState(() { _loadingProducts = false; }); }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('Categories', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
      body: _loadingCollections ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
          : _error != null ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadCollections, child: const Text('Retry')),
            ]))
          : Row(children: [
              Container(width: 110, color: Colors.white, child: ListView.builder(itemCount: _collections.length, itemBuilder: (_, i) {
                final col = _collections[i];
                final selected = col.id == _selectedCollection?.id;
                return GestureDetector(onTap: () => _selectCollection(col), child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(color: selected ? const Color(0xFFFF6B00).withOpacity(0.08) : Colors.transparent, border: selected ? const Border(left: BorderSide(color: Color(0xFFFF6B00), width: 3)) : null),
                  child: Column(children: [
                    col.imageUrl != null ? ClipOval(child: CachedNetworkImage(imageUrl: col.imageUrl!, width: 44, height: 44, fit: BoxFit.cover, errorWidget: (_, __, ___) => _icon(selected))) : _icon(selected),
                    const SizedBox(height: 6),
                    Text(col.title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? const Color(0xFFFF6B00) : const Color(0xFF444444))),
                  ]),
                ));
              })),
              Expanded(child: _loadingProducts ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
                  : _products.isEmpty ? const Center(child: Text('No products', style: TextStyle(color: Colors.grey)))
                  : GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: _products.length, itemBuilder: (_, i) => ProductCard(product: _products[i]))),
            ]),
    );
  }
  Widget _icon(bool selected) => Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? const Color(0xFFFF6B00).withOpacity(0.15) : Colors.grey[100]), child: Icon(Icons.category, color: selected ? const Color(0xFFFF6B00) : Colors.grey, size: 22));
}
