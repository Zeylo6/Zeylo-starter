import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'core/services/notification_service.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Phase 6: Initialize NotificationService (permissions, channel, listeners)
  await NotificationService.instance.initialize();

  // Set system UI overlay styles
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialize Stripe
  Stripe.publishableKey =
      "pk_test_51TCepJIpapJkUVVbudjFIjcd2en54Z0qjkjZ8nMl2f7eL9VsZ12ykDjyZ5MKtIffb1cHpairMGsQXBJJW4wXFlXV00bHBXtRVp";
  await Stripe.instance.applySettings();

  runApp(
    const ProviderScope(
      child: ZeyloApp(),
    ),
  );

  // Phase 6: Set up deep-link navigation when user taps a notification
  // Must be called AFTER runApp so GoRouter / Navigator are mounted.
  await NotificationService.instance.setupInteractedMessage(navigatorKey);
}
