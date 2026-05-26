import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  late ProductVariant _selectedVariant;
  int _quantity = 1;
  bool _addingToCart = false;

  @override
  void initState() {
    super.initState();
    _selectedVariant = widget.product.variants.isNotEmpty
        ? widget.product.variants.first
        : ProductVariant(
            id: '',
            title: 'Default',
            price: widget.product.price,
            currencyCode: 'AED',
            availableForSale: false,
          );
  }

  void _addToCart() {
    if (!_selectedVariant.availableForSale) return;

    setState(() => _addingToCart = true);

    final cart = Provider.of<CartProvider>(context, listen: false);
    for (var i = 0; i < _quantity; i++) {
      cart.addToCart(widget.product, _selectedVariant);
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _addingToCart = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product.title} added to cart'),
          backgroundColor: const Color(0xFFFF6B00),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final hasImages = product.images.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8)
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8)
                    ],
                  ),
                  child: const Icon(Icons.share_outlined,
                      color: Color(0xFF1A1A1A), size: 20),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: hasImages
                  ? Stack(
                      children: [
                        PageView.builder(
                          itemCount: product.images.length,
                          onPageChanged: (i) =>
                              setState(() => _selectedImageIndex = i),
                          itemBuilder: (_, i) => CachedNetworkImage(
                            imageUrl: product.images[i].src,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => Container(
                              color: Colors.grey[100],
                              child: const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFFFF6B00)),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey[100],
                              child: const Icon(Icons.image_not_supported,
                                  size: 60, color: Colors.grey),
                            ),
                          ),
                        ),
                        if (product.images.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                product.images.length,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  width: _selectedImageIndex == i ? 20 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _selectedImageIndex == i
                                        ? const Color(0xFFFF6B00)
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      color: Colors.grey[100],
                      child: const Icon(Icons.shopping_bag,
                          size: 80, color: Colors.grey),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedVariant.currencyCode == 'AED'
                            ? 'AED ${_selectedVariant.price.toStringAsFixed(2)}'
                            : '${_selectedVariant.currencyCode} ${_selectedVariant.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFF6B00),
                        ),
                      ),
                    ],
                  ),

                  if (product.vendor != null &&
                      product.vendor!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'by ${product.vendor}',
                      style: const TextStyle(
                          fontSize: 13, color: Colors.grey),
                    ),
                  ],

                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _selectedVariant.availableForSale
                          ? Colors.green[50]
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _selectedVariant.availableForSale
                          ? 'In Stock'
                          : 'Out of Stock',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _selectedVariant.availableForSale
                            ? Colors.green[700]
                            : Colors.red[700],
                      ),
                    ),
                  ),

                  if (product.variants.length > 1) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Select Option',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.variants.map((variant) {
                        final selected = variant.id == _selectedVariant.id;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedVariant = variant),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFFF6B00)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFFFF6B00)
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Text(
                              variant.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color:
                                    selected ? Colors.white : Colors.grey[700],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Text(
                    'Quantity',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _qtyButton(Icons.remove, () {
                        if (_quantity > 1)
                          setState(() => _quantity--);
                      }),
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ),
                      _qtyButton(Icons.add,
                          () => setState(() => _quantity++)),
                    ],
                  ),

                  if (product.description.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Description',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF555555),
                        height: 1.6,
                      ),
                    ),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, -4))
          ],
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed:
                _selectedVariant.availableForSale && !_addingToCart
                    ? _addToCart
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _addingToCart
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    _selectedVariant.availableForSale
                        ? 'Add to Cart'
                        : 'Out of Stock',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF1A1A1A)),
      ),
    );
  }
}
