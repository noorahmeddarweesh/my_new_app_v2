import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationPanelWidget extends StatelessWidget {
  final List notifications;
  final Function(int index) onTap;

  const NotificationPanelWidget({
    super.key,
    required this.notifications,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Header =====
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Notifications",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ===== Body =====
            Expanded(
              child: notifications.isEmpty
                  ? _emptyState()
                  : ListView.separated(
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: Colors.grey.shade300),
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        final bool isRead = item['isRead'] == true;
                        final DateTime time = item['time'];

                        return InkWell(
                          onTap: () {
                            // 🔹 حدث الـ provider
                            final id = item['id'];
                            Provider.of<NotificationProvider>(context, listen: false)
                                .markAsRead(id);

                            // 🔹 حدث الـ local item فورًا لتغيير اللون داخل الـ panel
                            if (!isRead) {
                              item['isRead'] = true;
                              (context as Element).markNeedsBuild();
                            }

                            onTap(index);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            color: isRead
                                ? Colors.white
                                : Colors.grey.shade100,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ===== Icon =====
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isRead
                                        ? Colors.grey.shade400
                                        : Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    item['icon'] ?? Icons.notifications,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // ===== Text =====
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'] ?? '',
                                        style: TextStyle(
                                          fontWeight: isRead
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Empty State =====
  Widget _emptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.notifications_off_outlined,
          size: 70,
          color: Colors.grey,
        ),
        SizedBox(height: 16),
        Text(
          "No notifications yet",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
