import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String userName = "";
  String email = "";
  
  String profileImage = "assets/images/default_profile.png";
  String? uid;
  bool isLoading = false;

  Future<void> loadUser(String userId) async {
    uid = userId;
    isLoading = true;
    notifyListeners();

    try {
      final doc = await _db.collection('users').doc(userId).get();

      if (doc.exists) {
        final data = doc.data()!;

        final firstName = data['firstName'] ?? "";
        final lastName = data['lastName'] ?? "";

        userName = "$firstName $lastName".trim();
        email = data['email'] ?? email;
        profileImage = data['profileImage'] ?? profileImage;
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateName(String newName) {
    userName = newName;
    notifyListeners();
  }

  void updateEmail(String newEmail) {
    email = newEmail;
    notifyListeners();
  }

  void updateImage(String newImage) {
    profileImage = newImage;
    notifyListeners();
  }

  Future<void> saveProfileToFirestore({
    required String fullName,
    required String newEmail,
    String? phone,
    String? newImage,
  }) async {
    if (uid == null) return;

    try {
      final names = fullName.trim().split(" ");

      await _db.collection('users').doc(uid).update({
        'firstName': names.first,
        'lastName': names.length > 1 ? names.last : '',
        'email': newEmail,
        if (phone != null) 'phone': phone,
        if (newImage != null) 'profileImage': newImage,
      });
      userName = fullName;
      email = newEmail;
      if (newImage != null) profileImage = newImage;

      notifyListeners();
    } catch (e) {
      debugPrint("Error saving profile: $e");
    }
  }

  void clear() {
    uid = null;
    userName = "";
    email = "";
    profileImage = "assets/images/default_profile.png";
    isLoading = false;
    notifyListeners();
  }
}
