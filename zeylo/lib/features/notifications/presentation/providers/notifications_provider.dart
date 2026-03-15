import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
