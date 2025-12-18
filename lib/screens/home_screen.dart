import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/profile_provider.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';
import 'wishist_screen.dart';
import 'login_screen.dart';
import '../widgets/home_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/welcome_card.dart';
import '../widgets/categories_list.dart';
import '../widgets/products_grid.dart';
import '../widgets/app_drawer.dart';
import '../widgets/notification_panel.dart';
import '../providers/notification_provider.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> categories = [];
  List products = [];
  List allProducts = [];
  List suggestionResults = [];

  String selectedCategory = "all";
  String searchQuery = "";

  bool showSuggestions = false;

  Timer? searchDelay;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchAllProducts();
    // 🔹 بدأ الاستماع للإشعارات بعد تحميل الwidget
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Provider.of<NotificationProvider>(context, listen: false)
          .startListening(user.uid);
    }
  });
  }

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  Future<void> fetchCategories() async {
    final url = Uri.parse("https://dummyjson.com/products/categories");
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      List<Map<String, String>> parsed = [];
      if (data is List) {
        for (var e in data) {
          if (e is String) {
            parsed.add({'slug': e, 'label': capitalize(e)});
          } else if (e is Map) {
            String slug = e['slug']?.toString() ?? e['name']?.toString() ?? e.toString();
            String label = e['name']?.toString() ?? (e['slug'] != null ? capitalize(e['slug'].toString()) : slug);
            parsed.add({'slug': slug, 'label': capitalize(label)});
          } else {
            final s = e.toString();
            parsed.add({'slug': s, 'label': capitalize(s)});
          }
        }
      }
      setState(() {
        categories = parsed;
      });
    }
  }

  Future<void> fetchAllProducts() async {
    final url = Uri.parse("https://dummyjson.com/products");
    final res = await http.get(url);
    if (res.statusCode == 200) {
      List data = json.decode(res.body)['products'];
      setState(() {
        allProducts = data;
        products = data;
        selectedCategory = "all";
      });
    }
  }

  Future<void> fetchByCategory(String catSlug) async {
    if (catSlug == "all") {
      setState(() {
        products = allProducts;
        selectedCategory = "all";
      });
      return;
    }

    final url = Uri.parse("https://dummyjson.com/products/category/$catSlug");
    final res = await http.get(url);
    if (res.statusCode == 200) {
      List data = json.decode(res.body)['products'];
      setState(() {
        products = data;
        selectedCategory = catSlug;
      });
    } else {
      List local = allProducts.where((p) {
        final cat = p['category']?.toString().toLowerCase() ?? "";
        return cat == catSlug.toLowerCase();
      }).toList();
      setState(() {
        products = local;
        selectedCategory = catSlug;
      });
    }
  }

  void updateSuggestions() {
    String q = searchQuery.trim().toLowerCase();

    if (q.isEmpty) {
      setState(() {
        suggestionResults = [];
        showSuggestions = false;
      });
      return;
    }

    List matches = allProducts.where((p) {
      String title = p['title'].toString().toLowerCase();
      String description = (p['description'] ?? "").toString().toLowerCase();
      String category = (p['category'] ?? "").toString().toLowerCase();
      return title.contains(q) || description.contains(q) || category.contains(q);
    }).toList();

    if (matches.length > 7) matches = matches.sublist(0, 7);

    setState(() {
      suggestionResults = matches;
      showSuggestions = matches.isNotEmpty;
    });
  }

  void onSubmitSearch(String value) {
    String q = value.trim().toLowerCase();

    if (q.isEmpty) {
      setState(() {
        products = allProducts;
        showSuggestions = false;
      });
      return;
    }

    final matchedCategory = categories.firstWhere(
      (c) => c['slug']!.toLowerCase() == q || c['label']!.toLowerCase() == q,
      orElse: () => {},
    );
    if (matchedCategory.isNotEmpty) {
      fetchByCategory(matchedCategory['slug']!);
      setState(() {
        showSuggestions = false;
        searchController.text = "";
      });
      return;
    }

    List results = allProducts.where((p) {
      String title = p['title'].toString().toLowerCase();
      String description = (p['description'] ?? "").toString().toLowerCase();
      return title.contains(q) || description.contains(q);
    }).toList();

    setState(() {
      products = results;
      showSuggestions = false;
    });

    if (results.isEmpty) {
      showNiceMessage(context, "لا يوجد منتج بهذا الاسم");
      return;
    }

    if (results.length == 1) {
      Future.microtask(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: results[0]),
          ),
        );
      });
    }
  }

  

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final profile = Provider.of<ProfileProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppDrawerWidget(
        profile: profile,
        onCategorySelected: fetchByCategory,
        categories: categories,
        onLogout: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Logout"),
              content: const Text("Are you sure you want to logout?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text("Logout"),
                ),
              ],
            ),
          );
        },
        onHomeTap: () => Navigator.pop(context),
        onWishlistTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WishlistScreen()),
          );
        },
        onCartTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          );
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeHeaderWidget(
  profile: profile,
  onNotificationTap: () => showNotificationPanel(context),
  onCartTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  },
),

                const SizedBox(height: 20),
                SearchBarWidget(
                  controller: searchController,
                  onChanged: (value) {
                    searchQuery = value;
                    searchDelay?.cancel();
                    searchDelay = Timer(
                      const Duration(milliseconds: 400),
                      updateSuggestions,
                    );
                  },
                  onSubmitted: onSubmitSearch,
                  showSuggestions: showSuggestions,
                  suggestionResults: suggestionResults,
                  onSuggestionTap: (item) {
                    setState(() {
                      showSuggestions = false;
                      searchController.clear();
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(product: item),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const WelcomeCardWidget(),
                const SizedBox(height: 20),
                CategoriesListWidget(
                  categories: categories,
                  selectedCategory: selectedCategory,
                  onCategoryTap: (value) {
                    searchController.clear();
                    searchQuery = "";
                    setState(() {
                      showSuggestions = false;
                    });
                    fetchByCategory(value);
                  },
                ),
                const SizedBox(height: 20),
                ProductsGridWidget(
                  products: products,
                  cartProvider: cartProvider,
                  wishlistProvider: wishlistProvider,
                  onProductTap: (item) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: item)),
                    );
                  },
                  onAddToCart: (item) {
                    cartProvider.addToCart(item);
                    showNiceMessage(context, "Added to cart");
                  },
                  onToggleWishlist: (item) {
                    bool isFav = wishlistProvider.isInWishlist(item['id']);
                    wishlistProvider.toggleWishlist(item);
                    showNiceMessage(context, isFav ? "Removed from wishlist" : "Added to wishlist");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showNiceMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  void showNotificationPanel(BuildContext context) {
  final notificationProvider =
      Provider.of<NotificationProvider>(context, listen: false);

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return NotificationPanelWidget(
        notifications: notificationProvider.notifications,
        onTap: (index) {
          final id =
              notificationProvider.notifications[index]['id'];
          notificationProvider.markAsRead(id);
        },
      );
    },
  );
}



  @override
  void dispose() {
    searchDelay?.cancel();
    searchController.dispose();
    super.dispose();
  }
}