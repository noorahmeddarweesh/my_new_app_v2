import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  StreamSubscription? _subscription;

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  void startListening(String uid) {
    _subscription?.cancel();
    _subscription = _firestore
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .orderBy('time', descending: true)
        .snapshots()
        .listen((snapshot) {
      _notifications = snapshot.docs.map((doc) {
        final Timestamp ts = doc['time'];
        return {
          "id": doc.id,
          "title": doc['title'],
          "orderId": doc['orderId'],
          "time": ts.toDate(),
          "isRead": doc['isRead'],
          "icon": _mapIcon(doc['icon']),
        };
      }).toList();

      _updateUnreadCount();
    });
  }

  IconData _mapIcon(String name) {
    switch (name) {
      case 'local_shipping':
        return Icons.local_shipping;
      case 'favorite':
        return Icons.favorite;
      default:
        return Icons.notifications;
    }
  }

  Future<void> markAsRead(String id) async {
    await _firestore.collection('notifications').doc(id).update({"isRead": true});

    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      _updateUnreadCount();
    }
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => n['isRead'] == false).length;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
