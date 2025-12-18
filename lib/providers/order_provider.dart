import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart' as myOrder; // <-- alias لتجنب تضارب

class OrderProvider with ChangeNotifier {
  List<myOrder.Order> _orders = [];

  List<myOrder.Order> get orders => _orders;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// تحميل أوردرات المستخدم الحالي
  Future<void> fetchMyOrders() async {
    final userId = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();

    _orders =
        snapshot.docs.map((doc) => myOrder.Order.fromFirestore(doc)).toList();

    notifyListeners();
  }

  /// إضافة أوردر جديد
  Future<void> addOrder(myOrder.Order order) async {
    final doc = await _firestore.collection('orders').add({
      'userId': order.userId,
      'fullName': order.fullName,
      'address': order.address,
      'phone': order.phone,
      'totalPrice': order.totalPrice,
      'cart': order.cart,
      'date': Timestamp.fromDate(order.date),
    });

    _orders.insert(0, order.copyWith(id: doc.id));
    notifyListeners();

    // ===== إنشاء Notification تلقائي مع userId =====
    await _firestore.collection('notifications').add({
      'userId': order.userId, // 👈 مهم عشان الـ Provider يعرف يفلتر
      'title': 'Your order has been placed successfully',
      'orderId': doc.id,
      'icon': 'local_shipping',
      'isRead': false,
      'time': FieldValue.serverTimestamp(),
    });
  }

  /// تحديث حالة الأوردر
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
    });

    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      //_orders[index].status = status; // لو أضفت status في الموديل
      notifyListeners();
    }
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }
}
