import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../firebase_options.dart';

class Env {
  Env._();

  static String get googleMapsAndroidApiKey =>
      dotenv.env['GOOGLE_MAPS_ANDROID_API_KEY'] ?? '';
  static String get googleMapsIosApiKey =>
      dotenv.env['GOOGLE_MAPS_IOS_API_KEY'] ?? '';
  static String get googleMapsWebApiKey =>
      dotenv.env['GOOGLE_MAPS_WEB_API_KEY'] ?? '';

  static FirebaseOptions get firebaseOptions {
    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: _value('FIREBASE_API_KEY', DefaultFirebaseOptions.web.apiKey),
        appId: _value('FIREBASE_APP_ID', DefaultFirebaseOptions.web.appId),
        messagingSenderId: _value(
          'FIREBASE_MESSAGING_SENDER_ID',
          DefaultFirebaseOptions.web.messagingSenderId,
        ),
        projectId:
            _value('FIREBASE_PROJECT_ID', DefaultFirebaseOptions.web.projectId),
        authDomain: _value(
          'FIREBASE_AUTH_DOMAIN',
          DefaultFirebaseOptions.web.authDomain ?? '',
        ),
        storageBucket: _value(
          'FIREBASE_STORAGE_BUCKET',
          DefaultFirebaseOptions.web.storageBucket ?? '',
        ),
        measurementId: _value(
          'FIREBASE_MEASUREMENT_ID',
          DefaultFirebaseOptions.web.measurementId ?? '',
        ),
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: _value(
            'FIREBASE_ANDROID_API_KEY',
            DefaultFirebaseOptions.android.apiKey,
          ),
          appId: _value(
            'FIREBASE_ANDROID_APP_ID',
            DefaultFirebaseOptions.android.appId,
          ),
          messagingSenderId: _value(
            'FIREBASE_MESSAGING_SENDER_ID',
            DefaultFirebaseOptions.android.messagingSenderId,
          ),
          projectId: _value(
            'FIREBASE_PROJECT_ID',
            DefaultFirebaseOptions.android.projectId,
          ),
          storageBucket: _value(
            'FIREBASE_STORAGE_BUCKET',
            DefaultFirebaseOptions.android.storageBucket ?? '',
          ),
        );
      case TargetPlatform.iOS:
        return FirebaseOptions(
          apiKey: _value(
            'FIREBASE_IOS_API_KEY',
            DefaultFirebaseOptions.ios.apiKey,
          ),
          appId: _value(
            'FIREBASE_IOS_APP_ID',
            DefaultFirebaseOptions.ios.appId,
          ),
          messagingSenderId: _value(
            'FIREBASE_MESSAGING_SENDER_ID',
            DefaultFirebaseOptions.ios.messagingSenderId,
          ),
          projectId:
              _value('FIREBASE_PROJECT_ID', DefaultFirebaseOptions.ios.projectId),
          storageBucket: _value(
            'FIREBASE_STORAGE_BUCKET',
            DefaultFirebaseOptions.ios.storageBucket ?? '',
          ),
          iosBundleId: _value(
            'FIREBASE_IOS_BUNDLE_ID',
            DefaultFirebaseOptions.ios.iosBundleId ?? '',
          ),
        );
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return DefaultFirebaseOptions.currentPlatform;
    }
  }

  static String _value(String key, String fallback) {
    final value = dotenv.env[key];
    if (value == null || value.trim().isEmpty) return fallback;
    return value;
  }
}
