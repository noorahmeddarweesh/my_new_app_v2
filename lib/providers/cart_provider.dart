import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _cart = [];

  List<Map<String, dynamic>> get cart => _cart;

  String get _uid => _auth.currentUser!.uid;


  Future<void> fetchCart() async {
    if (_auth.currentUser == null) return;

    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .get();

    _cart = snapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data(),
            })
        .toList();

    notifyListeners();
  }

  /// 🔥 ADD TO CART
  Future<void> addToCart(Map<String, dynamic> product) async {
    final docRef = _db
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .doc(product['id'].toString());

    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.update({
        'quantity': doc['quantity'] + 1,
      });
    } else {
      await docRef.set({
        'title': product['title'],
        'price': product['price'],
        'thumbnail': product['thumbnail'],
        'quantity': 1,
      });
    }

    await fetchCart();
  }

  /// 🔥 INCREASE
  Future<void> increaseQuantity(String productId, int currentQty) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .doc(productId)
        .update({'quantity': currentQty + 1});

    await fetchCart();
  }

  /// 🔥 DECREASE
  Future<void> decreaseQuantity(String productId, int currentQty) async {
    if (currentQty > 1) {
      await _db
          .collection('users')
          .doc(_uid)
          .collection('cart')
          .doc(productId)
          .update({'quantity': currentQty - 1});
    }
    await fetchCart();
  }

  /// 🔥 REMOVE ITEM
  Future<void> removeItem(String productId) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .doc(productId)
        .delete();

    await fetchCart();
  }

  /// 🔥 TOTAL
  double get total {
    double sum = 0;
    for (var p in _cart) {
      sum += (p['price'] as num) * (p['quantity'] as num);
    }
    return sum;
  }

  /// 🔥 CLEAR CART FROM FIRESTORE (after checkout)
  Future<void> clearCart() async {
    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    _cart = [];
    notifyListeners();
  }

  /// 🔥 VERY IMPORTANT: CLEAR LOCAL DATA ON LOGOUT
  void clearLocalCart() {
    _cart = [];
    notifyListeners();
  }
}