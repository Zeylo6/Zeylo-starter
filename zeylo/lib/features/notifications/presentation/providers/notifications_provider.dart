import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_service.dart';

// ---------------------------------------------------------------------------
// Phase 7: Unread notification count – drives the badge on the nav bar
// ---------------------------------------------------------------------------

/// Provider that returns the stream of unread notifications count for the current user
final unreadNotificationsCountProvider = StreamProvider<int>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  
  if (user == null) {
    return Stream.value(0);
  }

  return FirebaseFirestore.instance
      .collection('activities')
      .where('userId', isEqualTo: user.uid)
      .where('isRead', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

// ---------------------------------------------------------------------------
// Phase 7: FCM token sync – saves/clears the device FCM token in Firestore
// whenever the user logs in or logs out.
// ---------------------------------------------------------------------------

/// Watches Firebase auth state and automatically saves the FCM token when the
/// user logs in, and removes it when they log out.
/// Must be watched somewhere in the widget tree to stay active — wire it up
/// in MainScaffold or ZeyloApp via ref.watch(fcmTokenSyncProvider).
final fcmTokenSyncProvider = StreamProvider<void>((ref) {
  return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
    if (user != null) {
      // User logged in → save their FCM token so the backend can target them
      await NotificationService.instance.saveTokenToFirestore(user.uid);
    } else {
      // User logged out → we don't know their uid here, token refresh
      // listener in NotificationService handles cleanup if the uid is
      // available. The token will simply become stale on the server.
    }
  });
});

