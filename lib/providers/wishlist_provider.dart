import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> wishlist = [];

  String get _uid => _auth.currentUser!.uid;

  /// 🔥 FETCH WISHLIST FROM FIRESTORE
  Future<void> fetchWishlist() async {
    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('wishlist')
        .get();

    wishlist = snapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data(),
            })
        .toList();

    notifyListeners();
  }

  /// 🔥 TOGGLE WISHLIST
  Future<void> toggleWishlist(Map<String, dynamic> product) async {
    final docRef = _db
        .collection('users')
        .doc(_uid)
        .collection('wishlist')
        .doc(product['id'].toString());

    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.delete();
      wishlist.removeWhere((p) => p['id'] == product['id']);
    } else {
      await docRef.set({
        'title': product['title'],
        'price': product['price'],
        'thumbnail': product['thumbnail'],
      });
      wishlist.add(product);
    }

    notifyListeners();
  }

  bool isInWishlist(int id) {
    return wishlist.any((p) => p['id'] == id);
  }
}