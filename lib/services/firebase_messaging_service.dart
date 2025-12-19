import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> init() async {
    print("🟡 [FCM] init started");

    final settings = await _messaging.requestPermission();
    print("🟢 [FCM] Permission status: ${settings.authorizationStatus}");

    final token = await _messaging.getToken();

    if (token == null) {
      print("❌❌❌ [FCM] TOKEN IS NULL");
      return;
    }

    print("");
    print("🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥");
    print("🔥🔥🔥  FCM TOKEN FOUND  🔥🔥🔥");
    print("✅ TOKEN => $token");
    print("🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥");
    print("");

    final user = _auth.currentUser;
    if (user == null) {
      print("❌ [FCM] No logged-in user");
      return;
    }

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
      });
      print("✅✅ [FCM] Token saved to Firestore");
    } catch (e) {
      print("❌❌ [FCM] Failed to save token: $e");
    }

    print("🟢 [FCM] init finished");
  }
}
