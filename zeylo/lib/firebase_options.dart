// File generated based on Firebase project configuration.
// Do not manually edit this file.

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
        return web; // Fallback to web config
      case TargetPlatform.windows:
        return web;
      case TargetPlatform.linux:
        return web;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCl3tLYpR0uRrnCxzZLQygdxeU1V-o7hx0',
    appId: '1:808246523710:web:1d69fb5842c32f2e9f9e6f',
    messagingSenderId: '808246523710',
    projectId: 'zeylo-327c9',
    authDomain: 'zeylo-327c9.firebaseapp.com',
    storageBucket: 'zeylo-327c9.firebasestorage.app',
    measurementId: 'G-KPK0P1XJQG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBrB8E8bY4R1Bls_t9XBk9xDMh-aNnyJxM',
    appId: '1:808246523710:android:aef907866a32b0d29f9e6f',
    messagingSenderId: '808246523710',
    projectId: 'zeylo-327c9',
    storageBucket: 'zeylo-327c9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBtfjrr0vF17cAielcEXIr6Sq47U9adxpw',
    appId: '1:808246523710:ios:c1be7e814cfed1fe9f9e6f',
    messagingSenderId: '808246523710',
    projectId: 'zeylo-327c9',
    storageBucket: 'zeylo-327c9.firebasestorage.app',
    iosBundleId: 'com.zeylo.zeylo',
  );
}
