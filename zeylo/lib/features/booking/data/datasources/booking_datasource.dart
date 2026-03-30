import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/config/app_config.dart';
import '../models/booking_model.dart';

/// Abstract data source for booking operations
abstract class BookingDataSource {
  Future<BookingModel> createBooking(BookingModel booking);
  Future<BookingModel> getBookingById(String id);
  Future<List<BookingModel>> getUserBookings(String userId);
  Future<List<BookingModel>> getHostBookings(String hostId);
  Future<void> updateBookingStatus(String id, String status);
  Future<void> updatePaymentStatus(String id, String paymentStatus);
  Future<void> cancelBooking(String id);
}

/// Remote data source implementation using Firebase Firestore
class BookingRemoteDataSource implements BookingDataSource {
  final FirebaseFirestore firebaseFirestore;

  /// Collection reference for bookings
  late final CollectionReference<Map<String, dynamic>> _bookingsCollection;

  BookingRemoteDataSource({required this.firebaseFirestore}) {
    _bookingsCollection = firebaseFirestore.collection('bookings');
  }

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    try {
      final firestoreData = booking.toFirestore();
      print('[BookingDS] Creating booking: title="${booking.experienceTitle}" chainId=${booking.chainId} hostId=${booking.hostId}');
      print('[BookingDS] Firestore payload chainId: ${firestoreData['chainId']}');
      final docRef = await _bookingsCollection.add(firestoreData);
      
      // Create notification for host
      await firebaseFirestore.collection('activities').add({
        'userId': booking.hostId,
        'title': 'New Booking Request',
        'message': 'You have a new booking request for "${booking.experienceTitle}".',
        'type': 'new_booking',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'bookingId': docRef.id,
      });

      return booking.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  @override
  Future<BookingModel> getBookingById(String id) async {
    try {
      final doc = await _bookingsCollection.doc(id).get();
      if (!doc.exists) {
        throw Exception('Booking not found');
      }
      return BookingModel.fromFirestore(doc.data() ?? {}, doc.id);
    } catch (e) {
      throw Exception('Failed to get booking: $e');
    }
  }

  @override
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final querySnapshot =
          await _bookingsCollection.where('userId', isEqualTo: userId).get();

      final bookings = querySnapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc.data(), doc.id))
          .toList();

      // Sort in memory to avoid requiring a composite index
      bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return bookings;
    } catch (e) {
      throw Exception('Failed to get user bookings: $e');
    }
  }

  @override
  Future<List<BookingModel>> getHostBookings(String hostId) async {
    try {
      final querySnapshot =
          await _bookingsCollection.where('hostId', isEqualTo: hostId).get();

      final bookings = querySnapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc.data(), doc.id))
          .toList();

      // Sort in memory to avoid requiring a composite index  
      bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return bookings;
    } catch (e) {
      throw Exception('Failed to get host bookings: $e');
    }
  }

  @override
  Future<void> updateBookingStatus(String id, String status) async {
    try {
      await _bookingsCollection.doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Fetch booking to get user details for notification
      final booking = await getBookingById(id);
      
      String title = '';
      String message = '';
      String type = 'booking_update';

      final isMystery = booking.isMystery;

      if (status == 'accepted' || status == 'confirmed') {
        if (isMystery) {
          title = 'Mystery Experience Accepted! 🎁';
          message = 'Your host has accepted your mystery experience booking. Details will be revealed 48 hours before!';
          type = 'mystery_booking_accepted';
        } else {
          title = 'Booking Accepted! ✅';
          message = 'Your booking for "${booking.experienceTitle}" has been accepted by the host.';
          type = 'booking_accepted';
        }
      } else if (status == 'rejected') {
        if (isMystery) {
          title = 'Mystery Booking Declined';
          message = 'Sorry, your mystery experience booking was declined by the host.';
          type = 'mystery_booking_declined';
        } else {
          title = 'Booking Declined';
          message = 'Sorry, your booking for "${booking.experienceTitle}" was declined.';
          type = 'booking_rejected';
        }
      } else if (status == 'completed') {
        title = 'Experience Completed ⭐';
        message = 'We hope you enjoyed "${booking.experienceTitle}"! Please leave a review.';
        type = 'booking_completed';
      } else if (status == 'mystery_revealed') {
        title = 'Mystery Revealed! 🎁';
        message = 'Your mystery experience is revealed! Check your bookings to accept or decline.';
        type = 'mystery_revealed';
      } else if (status == 'mystery_accepted') {
        title = 'Mystery Experience Confirmed! 🎉';
        message = 'You accepted your mystery experience. Get ready for your adventure!';
        type = 'mystery_accepted';
      } else if (status == 'mystery_declined') {
        title = 'Mystery Experience Declined';
        message = 'You declined the mystery experience booking.';
        type = 'mystery_declined';
      }

      if (title.isNotEmpty) {
        await firebaseFirestore.collection('activities').add({
          'userId': booking.userId,
          'title': title,
          'message': message,
          'type': type,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
          'bookingId': id,
        });
      }

      // If rejected, trigger backend refund
      if (status == 'rejected') {
        try {
          final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
          await http.post(
            Uri.parse('${AppConfig.baseUrl}/api/payments/refund'),
            body: jsonEncode({'bookingId': id}),
            headers: {
              'Content-Type': 'application/json',
              if (idToken != null) 'Authorization': 'Bearer $idToken',
            },
          );
        } catch (e) {
          print('Refund error: $e');
          // Allow it to fail gracefully without blocking the notification
        }
      }
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  @override
  Future<void> updatePaymentStatus(String id, String paymentStatus) async {
    try {
      await _bookingsCollection.doc(id).update({
        'paymentStatus': paymentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  @override
  Future<void> cancelBooking(String id) async {
    try {
      // Fetch booking to notify host/seeker
      final booking = await getBookingById(id);

      await _bookingsCollection.doc(id).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If seeker cancelled, notify host. If host cancelled (rare flow), notify seeker.
      // Assuming for now it's seeker cancelling.
      await firebaseFirestore.collection('activities').add({
        'userId': booking.hostId,
        'title': 'Booking Cancelled',
        'message': 'A booking for "${booking.experienceTitle}" has been cancelled.',
        'type': 'booking_cancelled',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'bookingId': id,
      });
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }
}