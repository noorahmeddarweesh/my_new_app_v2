import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../screens/home_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/wishist_screen.dart';
import '../screens/profile_screen.dart';
import '../providers/profile_provider.dart';

class MainLayout extends StatefulWidget {
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Provider.of<ProfileProvider>(context, listen: false)
            .loadUser(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const WishlistScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: pages[currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(45),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              navItem(Icons.home, 0),
              navItem(Icons.favorite_border, 1),
              navItem(Icons.shopping_bag_outlined, 2),
              navItem(Icons.person_outline, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget navItem(IconData icon, int index) {
    bool active = index == currentIndex;

    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? Colors.white : Colors.white10,
        ),
        child: Icon(
          icon,
          size: 26,
          color: active ? Colors.black : Colors.white54,
        ),
      ),
    );
  }
}
