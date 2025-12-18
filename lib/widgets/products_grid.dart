import 'package:flutter/material.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';

class ProductsGridWidget extends StatelessWidget {
  final List products;
  final CartProvider cartProvider;
  final WishlistProvider wishlistProvider;
  final Function(dynamic) onProductTap;
  final Function(dynamic) onAddToCart;
  final Function(dynamic) onToggleWishlist;

  const ProductsGridWidget({
    super.key,
    required this.products,
    required this.cartProvider,
    required this.wishlistProvider,
    required this.onProductTap,
    required this.onAddToCart,
    required this.onToggleWishlist,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        return ProductCardWidget(
          item: products[index],
          cartProvider: cartProvider,
          wishlistProvider: wishlistProvider,
          onProductTap: onProductTap,
          onAddToCart: onAddToCart,
          onToggleWishlist: onToggleWishlist,
        );
      },
    );
  }
}

class ProductCardWidget extends StatelessWidget {
  final dynamic item;
  final CartProvider cartProvider;
  final WishlistProvider wishlistProvider;
  final Function(dynamic) onProductTap;
  final Function(dynamic) onAddToCart;
  final Function(dynamic) onToggleWishlist;

  const ProductCardWidget({
    super.key,
    required this.item,
    required this.cartProvider,
    required this.wishlistProvider,
    required this.onProductTap,
    required this.onAddToCart,
    required this.onToggleWishlist,
  });

  @override
  Widget build(BuildContext context) {
    bool isFav = wishlistProvider.isInWishlist(item['id']);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Center(
                    child: GestureDetector(
                      onTap: () => onProductTap(item),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 35),
                        child: Image.network(
                          item['thumbnail'],
                          width: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => onToggleWishlist(item),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: isFav ? Colors.red : Colors.black,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -10,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => onAddToCart(item),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shopping_bag, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              "Shop",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${item['price'] ?? ''}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(item['rating']?.toString() ?? ''),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}