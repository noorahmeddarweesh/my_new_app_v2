import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/notification_provider.dart';

class HomeHeaderWidget extends StatelessWidget {
  final ProfileProvider profile;
  final VoidCallback onNotificationTap;
  final VoidCallback onCartTap;

  const HomeHeaderWidget({
    super.key,
    required this.profile,
    required this.onNotificationTap,
    required this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: profile.profileImage.startsWith('assets')
                  ? AssetImage(profile.profileImage)
                  : FileImage(File(profile.profileImage)) as ImageProvider,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, ${profile.userName}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Text(
                  "Welcome back!",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),

        Row(
          children: [
            GestureDetector(
              onTap: onNotificationTap,
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_none),
                  ),

                  if (notificationProvider.unreadCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          notificationProvider.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            GestureDetector(
              onTap: onCartTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.shopping_bag_outlined, color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
