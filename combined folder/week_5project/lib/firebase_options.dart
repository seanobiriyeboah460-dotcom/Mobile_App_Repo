import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDs2fFaMil8SQP0jie30gQOuo43126prGU',
    appId: '1:182623220082:web:37b59b6393e526e60cedeb',
    messagingSenderId: '182623220082',
    projectId: 'week5firebase-c2bcd',
    authDomain: 'week5firebase-c2bcd.firebaseapp.com',
    storageBucket: 'week5firebase-c2bcd.firebasestorage.app',
    measurementId: 'G-1G3P9EZDC4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA8K5MIdWRS6sH4J99DQoM1XHuI1oCMrDQ',
    appId: '1:182623220082:android:93f24f5363f45bce0cedeb',
    messagingSenderId: '182623220082',
    projectId: 'week5firebase-c2bcd',
    storageBucket: 'week5firebase-c2bcd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDqJ8TatgRfmACmxxL3A9NaKhroUPYm7bY',
    appId: '1:182623220082:ios:420e64e5bcf59ca00cedeb',
    messagingSenderId: '182623220082',
    projectId: 'week5firebase-c2bcd',
    storageBucket: 'week5firebase-c2bcd.firebasestorage.app',
    iosBundleId: 'com.example.week5project',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDqJ8TatgRfmACmxxL3A9NaKhroUPYm7bY',
    appId: '1:182623220082:ios:420e64e5bcf59ca00cedeb',
    messagingSenderId: '182623220082',
    projectId: 'week5firebase-c2bcd',
    storageBucket: 'week5firebase-c2bcd.firebasestorage.app',
    iosBundleId: 'com.example.week5project',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDs2fFaMil8SQP0jie30gQOuo43126prGU',
    appId: '1:182623220082:web:40cc7a8ec16ef5600cedeb',
    messagingSenderId: '182623220082',
    projectId: 'week5firebase-c2bcd',
    authDomain: 'week5firebase-c2bcd.firebaseapp.com',
    storageBucket: 'week5firebase-c2bcd.firebasestorage.app',
    measurementId: 'G-DWBHELP8D2',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDs2fFaMil8SQP0jie30gQOuo43126prGU',
    appId: '1:182623220082:web:40cc7a8ec16ef5600cedeb',
    messagingSenderId: '182623220082',
    projectId: 'week5firebase-c2bcd',
    storageBucket: 'week5firebase-c2bcd.firebasestorage.app',
  );

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
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions.currentPlatform is not supported for this platform.',
        );
    }
  }
}
