import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBmLmsxXaHi1RrfoZU85m3yhmoKUrjItEs',
    appId: '1:752172494786:web:6cd92bc2d692e90611b05b',
    messagingSenderId: '752172494786',
    projectId: 'my-new-app-952ba',
    authDomain: 'my-new-app-952ba.firebaseapp.com',
    storageBucket: 'my-new-app-952ba.firebasestorage.app',
    measurementId: 'G-ZV57PWMZQS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAXvB-DNGA6bnZ1oLUyImfs-7xhlxztXuY',
    appId: '1:752172494786:android:30e0f700e2769e8811b05b',
    messagingSenderId: '752172494786',
    projectId: 'my-new-app-952ba',
    storageBucket: 'my-new-app-952ba.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAA4aT1IARdD6W_fqm9OLbaCCoKSqeckOo',
    appId: '1:752172494786:ios:0b23dd2616d4091011b05b',
    messagingSenderId: '752172494786',
    projectId: 'my-new-app-952ba',
    storageBucket: 'my-new-app-952ba.firebasestorage.app',
    iosBundleId: 'com.example.myNewApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAA4aT1IARdD6W_fqm9OLbaCCoKSqeckOo',
    appId: '1:752172494786:ios:0b23dd2616d4091011b05b',
    messagingSenderId: '752172494786',
    projectId: 'my-new-app-952ba',
    storageBucket: 'my-new-app-952ba.firebasestorage.app',
    iosBundleId: 'com.example.myNewApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBmLmsxXaHi1RrfoZU85m3yhmoKUrjItEs',
    appId: '1:752172494786:web:3db2e0f4a57ae9c611b05b',
    messagingSenderId: '752172494786',
    projectId: 'my-new-app-952ba',
    authDomain: 'my-new-app-952ba.firebaseapp.com',
    storageBucket: 'my-new-app-952ba.firebasestorage.app',
    measurementId: 'G-8H7FGWJG8F',
  );
}
