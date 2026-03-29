import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_config.dart';

class StripePaymentService {
  static Future<String?> makePayment(
      double amount, String bookingId, String email,
      {String type = 'booking', String? mysteryId}) async {
    // Stripe's initPaymentSheet / presentPaymentSheet are not supported on Web.
    // Users must use the mobile app (Android / iOS) to complete payments.
    if (kIsWeb) {
      throw UnsupportedError(
        'Payments are only available on the Zeylo mobile app. '
        'Please download the app on Android or iOS to complete your booking.',
      );
    }

    try {
      // 1. Get auth token (Proving to the backend who the user is)
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();

      // 2. Call backend to create PaymentIntent
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/payments/create-intent'),
        body: jsonEncode({
          'amount': amount,
          'bookingId': bookingId,
          'email': email,
          'type': type,
          if (mysteryId != null) 'mysteryId': mysteryId,
        }),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
          //Securing the endpoint
        },
      );

      final data = jsonDecode(response
          .body); // This contains the client secrete that is recieved from stripe
      final paymentIntentId = data['paymentIntentId'] as String?;

      // 3. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: data['clientSecret'],
          merchantDisplayName: 'Zeylo',
        ),
      );

      // 4. Present Payment Sheet
      //This pops up the native UI where the user enters their card details
      //The card details entirely bipass the node.js backend (Stripe handles it directly)
      await Stripe.instance.presentPaymentSheet();

      return paymentIntentId;
    } catch (e) {
      print('Payment failed: $e');
      rethrow;
    }
  }
}
