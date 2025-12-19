import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import 'edit_profile_screen.dart';
import 'wishist_screen.dart';
import 'cart_screen.dart';
import 'my_orders_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> handleLogout(BuildContext context) async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    profileProvider.clear();

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<ProfileProvider>(
          builder: (context, profile, child) {
            if (profile.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            ImageProvider imageProvider;
            if (profile.profileImage.startsWith('assets/')) {
              imageProvider = AssetImage(profile.profileImage);
            } else {
              imageProvider = FileImage(File(profile.profileImage));
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: imageProvider,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.userName,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F3FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      profile.email,
                      style: const TextStyle(
                          color: Colors.black87, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        profileItem(
                          context,
                          icon: Icons.edit_outlined,
                          text: "Edit Profile",
                          page: const EditProfile(),
                        ),
                        divider(),
                        profileItem(
                          context,
                          icon: Icons.favorite_border,
                          text: "Wishlist",
                          page: const WishlistScreen(),
                        ),
                        divider(),
                        profileItem(
                          context,
                          icon: Icons.shopping_cart_outlined,
                          text: "My Cart",
                          page: const CartScreen(),
                        ),
                        divider(),
                        profileItem(
                          context,
                          icon: Icons.receipt_long,
                          text: "My Orders",
                          page: const MyOrdersScreen(),
                        ),
                        divider(),
                        ListTile(
                          leading:
                              const Icon(Icons.logout, color: Colors.red),
                          title: const Text(
                            "Logout",
                            style: TextStyle(
                                color: Colors.red, fontSize: 16),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.red),
                          onTap: () => handleLogout(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget profileItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Widget page,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        text,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }

  Widget divider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      color: Colors.grey.shade300,
    );
  }
}
