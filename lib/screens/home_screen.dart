import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/product.dart';
import '../services/shopify_service.dart';
import '../widgets/product_card.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _featuredProducts = [];
  List<Product> _allProducts = [];
  List<Collection> _collections = [];
  bool _loading = true;
  String? _error;
  int _bannerIndex = 0;

  final List<Map<String, String>> _banners = [
    {'title': 'Discover LEE Market', 'subtitle': 'Shop the best products in UAE', 'color': '#FF6B00'},
    {'title': 'Free Shipping', 'subtitle': 'On orders over AED 150', 'color': '#E55A00'},
    {'title': 'New Arrivals', 'subtitle': 'Fresh products every week', 'color': '#FF8C3A'},
  ];

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        ShopifyService.fetchProducts(limit: 8),
        ShopifyService.fetchProducts(limit: 20),
        ShopifyService.fetchCollections(limit: 10),
      ]);
      if (mounted) setState(() {
        _featuredProducts = results[0] as List<Product>;
        _allProducts = results[1] as List<Product>;
        _collections = results[2] as List<Collection>;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)), child: const Text('LEE', style: TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.w900, fontSize: 18))),
          const SizedBox(width: 8),
          const Text('Market', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()))),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
          : _error != null ? _buildError()
          : RefreshIndicator(
              color: const Color(0xFFFF6B00),
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildBannerCarousel(),
                  const SizedBox(height: 16),
                  if (_collections.isNotEmpty) _buildCategoriesRow(),
                  const SizedBox(height: 20),
                  _buildSectionHeader('Featured Products'),
                  const SizedBox(height: 12),
                  _buildFeaturedRow(),
                  const SizedBox(height: 20),
                  _buildSectionHeader('All Products'),
                  const SizedBox(height: 12),
                  _buildGrid(),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
    );
  }

  Widget _buildBannerCarousel() => Column(children: [
    CarouselSlider(
      options: CarouselOptions(height: 180, viewportFraction: 1.0, autoPlay: true, autoPlayInterval: const Duration(seconds: 4), onPageChanged: (i, _) => setState(() => _bannerIndex = i)),
      items: _banners.map((b) {
        final color = Color(int.parse(b['color']!.replaceAll('#', '0xFF')));
        return Container(width: double.infinity, decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withOpacity(0.7)])),
          child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(b['title']!, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(b['subtitle']!, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text('Shop Now', style: TextStyle(fontWeight: FontWeight.w700))),
          ])));
      }).toList(),
    ),
    const SizedBox(height: 10),
    AnimatedSmoothIndicator(activeIndex: _bannerIndex, count: _banners.length, effect: const WormEffect(dotHeight: 6, dotWidth: 6, activeDotColor: Color(0xFFFF6B00), dotColor: Color(0xFFD9D9D9))),
  ]);

  Widget _buildCategoriesRow() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _buildSectionHeader('Categories'),
    const SizedBox(height: 12),
    SizedBox(height: 90, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _collections.length, itemBuilder: (_, i) {
      final c = _collections[i];
      return Container(width: 70, margin: const EdgeInsets.only(right: 12), child: Column(children: [
        Container(width: 56, height: 56, decoration: BoxDecoration(color: const Color(0xFFFF6B00).withOpacity(0.1), shape: BoxShape.circle),
          child: c.imageUrl != null ? ClipOval(child: CachedNetworkImage(imageUrl: c.imageUrl!, fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(Icons.category, color: Color(0xFFFF6B00)))) : const Icon(Icons.category, color: Color(0xFFFF6B00), size: 24)),
        const SizedBox(height: 6),
        Text(c.title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
      ]));
    })),
  ]);

  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))));

  Widget _buildFeaturedRow() => SizedBox(height: 220, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _featuredProducts.length, itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(right: 12), child: ProductCard(product: _featuredProducts[i], width: 150))));

  Widget _buildGrid() => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12), itemCount: _allProducts.length, itemBuilder: (_, i) => ProductCard(product: _allProducts[i])));

  Widget _buildError() => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
    const SizedBox(height: 16),
    const Text('Could not load products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
    const SizedBox(height: 24),
    ElevatedButton(onPressed: _loadData, child: const Text('Try Again')),
  ])));
}
