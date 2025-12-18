import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// 🔥 EMAIL / PASSWORD SIGN UP
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _createUserIfNotExists(
      uid: cred.user!.uid,
      email: email,
      firstName: firstName,
      lastName: lastName,
    );

    return cred.user;
  }

  /// 🔥 EMAIL / PASSWORD LOGIN
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  /// 🔥 GOOGLE SIGN IN
  Future<User?> signInWithGoogle({bool forceChooseAccount = false}) async {
    // Force choose account for Sign Up
    final googleUser = await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
    
    // Optionally force account choice
    if (forceChooseAccount) {
      await _googleSignIn.disconnect();
      final selectedUser = await _googleSignIn.signIn();
      if (selectedUser == null) return null;
      return _firebaseSignInWithGoogle(selectedUser);
    }

    if (googleUser == null) return null;
    return _firebaseSignInWithGoogle(googleUser);
  }

  Future<User?> _firebaseSignInWithGoogle(GoogleSignInAccount googleUser) async {
    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);

    await _createUserIfNotExists(
      uid: userCred.user!.uid,
      email: userCred.user!.email ?? "",
      firstName: userCred.user!.displayName?.split(" ").first ?? "",
      lastName: userCred.user!.displayName?.split(" ").last ?? "",
    );

    return userCred.user;
  }
  /// 🔥 FACEBOOK SIGN IN
Future<User?> signInWithFacebook() async {
  print("🔹 Facebook Login started"); // Debug: بدء العملية
  try {
    final LoginResult result = await FacebookAuth.instance.login();

    print("🔹 LoginResult.status = ${result.status}");
    print("🔹 LoginResult.message = ${result.message}");

    if (result.status != LoginStatus.success) {
      print("❌ Facebook login failed!");
      return null;
    }

    final OAuthCredential credential =
        FacebookAuthProvider.credential(result.accessToken!.token);

    final userCred = await _auth.signInWithCredential(credential);

    print("✅ Facebook login success: ${userCred.user?.uid}");

    await _createUserIfNotExists(
      uid: userCred.user!.uid,
      email: userCred.user!.email ?? "",
      firstName: userCred.user!.displayName?.split(" ").first ?? "",
      lastName: userCred.user!.displayName?.split(" ").last ?? "",
    );

    return userCred.user;
  } catch (e) {
    print("❌ Exception during Facebook login: $e");
    return null;
  }
}

  /// 🔥 SIGN OUT
  Future<void> signOut({bool google = true}) async {
    await _auth.signOut();
    if (google) await _googleSignIn.signOut();
  }

  /// 🔥 CREATE USER ON FIRESTORE (ONCE)
  Future<void> _createUserIfNotExists({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) {
     await _db.collection('users').doc(uid).set({
  'uid': uid,
  'email': email,
  'firstName': firstName,
  'lastName': lastName,
  'phone': '',
  'profileImage': 'assets/images/default.png',
  'address': {
    'street': '',
    'city': '',
    'state': '',
    'zip': '',
    'country': '',
  },
  'createdAt': FieldValue.serverTimestamp(),
});

    }
  }
}
