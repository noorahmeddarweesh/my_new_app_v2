import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final dynamic product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  int currentImage = 0;
  late AnimationController favController;
  String selectedSize = "";
  List<Map<String, dynamic>> relatedProducts = [];

  @override
  void initState() {
    super.initState();
    favController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    fetchRelatedProducts();
  }

  Future<void> fetchRelatedProducts() async {
    try {
      final category = widget.product['category'];
      final id = widget.product['id'];
      final url = Uri.parse("https://dummyjson.com/products/category/$category");
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final allProducts =
            List<Map<String, dynamic>>.from(json.decode(res.body)['products']);
        setState(() {
          relatedProducts = allProducts.where((p) => p['id'] != id).toList();
        });
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    favController.dispose();
    super.dispose();
  }

  List<String> _getSizesForProduct(Map product) {
    final category = (product['category'] ?? '').toString().toLowerCase();
    final normalized = category.replaceAll("-", " ").trim();

    final clothingKeywords = [
      "shirt",
      "tshirt",
      "dress",
      "hoodie",
      "clothe",
      "jacket",
      "jeans",
      "pants",
      "skirt",
      "blouse",
      "top"
    ];

    final shoesKeywords = [
      "shoe",
      "sneaker",
      "boot",
      "heels",
      "sandal"
    ];

    if (clothingKeywords.any((k) => normalized == k || normalized.startsWith("$k "))) {
      return ["S", "M", "L", "XL", "XXL"];
    }

    if (shoesKeywords.any((k) => normalized == k || normalized.startsWith("$k "))) {
      return ["36","37","38","39","40","41","42","43","44","45"];
    }

    return [];
  }

  List<String> _getColorsForProduct(Map product) {
    List<String> colors = [];

    try {
      if (product["meta"] != null && product["meta"]["color"] != null) {
        colors.add(product["meta"]["color"].toString());
      }

      if (product["tags"] != null) {
        final commonColors = [
          "black", "white", "red", "blue", "green",
          "yellow", "pink", "brown", "gray", "beige"
        ];

        for (var t in product["tags"]) {
          final tag = t.toString().toLowerCase();
          if (commonColors.contains(tag)) {
            colors.add(t.toString());
          }
        }
      }
    } catch (e) {}

    return colors.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.product;
    final sizesList = _getSizesForProduct(item);
    final colorsList = _getColorsForProduct(item);

    final List<String> rawImages = List<String>.from(item['images'] ?? []);
    final List<String> images = [
      if (!rawImages.contains(item['thumbnail'])) item['thumbnail'],
      ...rawImages
    ];

    final cartProvider = Provider.of<CartProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    final bool isFav = wishlistProvider.isInWishlist(item['id']);

    final int cartQuantity = (() {
      final idx = cartProvider.cart.indexWhere((p) => p['id'] == item['id']);
      return idx >= 0 ? (cartProvider.cart[idx]['quantity'] as int) : 0;
    })();

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.1),
        elevation: 0,
        leading: _circleBtn(
          icon: Icons.arrow_back,
          onTap: () => Navigator.pop(context),
        ),
        actions: [
          _circleBtn(
            icon: isFav ? Icons.favorite : Icons.favorite_border,
            activeIconColor: Colors.black,
            onTap: () {
              wishlistProvider.toggleWishlist({
                "id": item['id'],
                "title": item['title'],
                "price": item['price'],
                "thumbnail": item['thumbnail'],
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isFav ? "Removed from wishlist" : "Added to wishlist"),
                  duration: const Duration(milliseconds: 900),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.05)),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: SizedBox(
                height: 350,
                child: PageView.builder(
                  itemCount: images.length,
                  onPageChanged: (i) => setState(() => currentImage = i),
                  itemBuilder: (context, index) {
                    return Hero(
                      tag: "${item['id']}_$index",
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, err, st) =>
                            const Center(child: Icon(Icons.broken_image)),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: currentImage == i ? 18 : 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: currentImage == i ? Colors.black : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title'] ?? '',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  Text("\$${item['price']}",
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 5),
                      Text(item['rating'].toString(),
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Text("${item['stock']} in stock",
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),

                  if (sizesList.isNotEmpty) _sizeSelector(sizesList),

                  if (colorsList.isNotEmpty) _colorSelector(colorsList),

                  const SizedBox(height: 25),
                  const Text("Description",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),

                  Text(item["description"] ?? "",
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 25),

                  const Text("Highlights",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  _highlight("- High quality material"),
                  _highlight("- Fast delivery"),
                  _highlight("- Best seller"),

                  const SizedBox(height: 40),

                  const Text("Related Products",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 260,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: relatedProducts.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final p = relatedProducts[index];
                        return SizedBox(width: 160, child: _relatedProductCard(p));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: _bottomBar(cartProvider, cartQuantity),
    );
  }

  Widget _highlight(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 15)),
      );

  Widget _sizeSelector(List<String> sizes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        const Text("Select Size",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          children: sizes.map((s) {
            bool active = selectedSize == s;
            return GestureDetector(
              onTap: () => setState(() => selectedSize = s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: active ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black12),
                ),
                child: Text(s,
                    style: TextStyle(
                        color: active ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _colorSelector(List<String> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        const Text("Available Colors",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          children: colors.map((c) {
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: Text(
                c.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required Function onTap,
    Color activeIconColor = Colors.black,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        margin: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
        child: Icon(icon, color: activeIconColor, size: 20),
      ),
    );
  }

  Widget _bottomBar(CartProvider cartProvider, int cartQuantity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (cartQuantity > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.black, borderRadius: BorderRadius.circular(10)),
                child: Text("$cartQuantity x",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  cartProvider.addToCart({
                    "id": widget.product['id'],
                    "title": widget.product['title'],
                    "price": widget.product['price'],
                    "thumbnail": widget.product['thumbnail'],
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Added to cart"),
                        duration: Duration(milliseconds: 900)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  "Add to Cart",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _relatedProductCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(item['thumbnail'], fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Consumer<WishlistProvider>(
                    builder: (context, wishlistProvider, _) {
                      final isFavRelated =
                          wishlistProvider.isInWishlist(item['id']);
                      return _circleBtn(
                        icon: isFavRelated ? Icons.favorite : Icons.favorite_border,
                        activeIconColor: Colors.black,
                        onTap: () {
                          wishlistProvider.toggleWishlist({
                            "id": item['id'],
                            "title": item['title'],
                            "price": item['price'],
                            "thumbnail": item['thumbnail'],
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  isFavRelated ? "Removed from wishlist" : "Added to wishlist"),
                              duration: const Duration(milliseconds: 900),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            const Padding(
                padding: EdgeInsets.all(8.0), child: SizedBox.shrink()),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text("\$${item['price']}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}