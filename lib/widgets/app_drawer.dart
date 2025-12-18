import 'dart:io';
import 'package:flutter/material.dart';
import '../providers/profile_provider.dart';
import '../screens/cart_screen.dart';
import '../screens/wishist_screen.dart';
import '../screens/login_screen.dart';

class AppDrawerWidget extends StatelessWidget {
  final ProfileProvider profile;
  final Function(String) onCategorySelected;
  final List<Map<String, String>> categories;
  final VoidCallback onLogout;
  final VoidCallback onHomeTap;
  final VoidCallback onWishlistTap;
  final VoidCallback onCartTap;

  const AppDrawerWidget({
    super.key,
    required this.profile,
    required this.onCategorySelected,
    required this.categories,
    required this.onLogout,
    required this.onHomeTap,
    required this.onWishlistTap,
    required this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.black),
            accountName: Text(profile.userName),
            accountEmail: Text(profile.email),
            currentAccountPicture: CircleAvatar(
              backgroundImage: profile.profileImage.startsWith('assets')
                  ? AssetImage(profile.profileImage)
                  : FileImage(File(profile.profileImage)) as ImageProvider,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: onHomeTap,
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text("My Wishlist"),
            onTap: onWishlistTap,
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined),
            title: const Text("My Cart"),
            onTap: onCartTap,
          ),
          const Divider(),
          ExpansionTile(
            leading: const Icon(Icons.category),
            title: const Text("All Categories"),
            children: [
              ListTile(
                title: const Text("All"),
                onTap: () {
                  Navigator.pop(context);
                  onCategorySelected("all");
                },
              ),
              ...categories.map((cat) {
                return ListTile(
                  title: Text(cat["label"]!),
                  onTap: () {
                    Navigator.pop(context);
                    onCategorySelected(cat["slug"]!);
                  },
                );
              }).toList(),
            ],
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}