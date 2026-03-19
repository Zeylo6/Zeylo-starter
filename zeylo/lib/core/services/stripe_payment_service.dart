import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

class StripePaymentService {
  static Future<void> makePayment(double amount, String bookingId) async {
    try {
      // 1. Get auth token
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();

      // 2. Call backend to create PaymentIntent
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/payments/create-intent'),
        body: jsonEncode({'amount': amount, 'bookingId': bookingId}),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      );

      final data = jsonDecode(response.body);

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: data['clientSecret'],
          merchantDisplayName: 'Zeylo',
        ),
      );

      // 3. Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      print('Payment failed: $e');
      rethrow;
    }
  }
}
