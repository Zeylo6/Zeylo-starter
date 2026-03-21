import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ---------------------------------------------------------------------------
// Phase 3 – Background message handler (MUST be a top-level function)
// This is called by FCM when the app is in the background or terminated.
// Firebase must already be initialized before this is invoked.
// ---------------------------------------------------------------------------
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[NotificationService] Background message received: ${message.messageId}');
  // flutter_local_notifications is NOT available in background isolates on
  // Android; FCM shows the notification natively from the "notification"
  // payload.  If you need custom handling, do it here.
}

// ---------------------------------------------------------------------------
// Phase 3 – Android notification channel
// A high-importance channel guarantees heads-up (pop-over) notifications.
// ---------------------------------------------------------------------------
const AndroidNotificationChannel _highImportanceChannel =
    AndroidNotificationChannel(
  'high_importance_channel', // must match AndroidManifest.xml meta-data
  'High Importance Notifications',
  description:
      'This channel is used for all Zeylo push notifications.',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

// ---------------------------------------------------------------------------
// Phase 3 – NotificationService
// ---------------------------------------------------------------------------
class NotificationService {
  // Singleton
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // -------------------------------------------------------------------------
  // Phase 3 – initialize()
  // Call once in main() after Firebase.initializeApp().
  // -------------------------------------------------------------------------
  Future<void> initialize() async {
    // 1. Register background handler (must be done before any other FCM call)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Request permissions (iOS + Android 13+)
    await _requestPermissions();

    // 3. Create the high-importance Android channel
    await _localPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_highImportanceChannel);

    // 4. Initialise flutter_local_notifications
    const InitializationSettings initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _localPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
    );

    // 5. Make iOS show banner + sound + badge when app is in the foreground
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 6. Listen for foreground FCM messages and show a local heads-up
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    debugPrint('[NotificationService] Initialized.');
  }

  // -------------------------------------------------------------------------
  // Phase 4 – saveTokenToFirestore()
  // Saves/updates the FCM token for the given user in Firestore so the
  // backend can target individual devices when sending push notifications.
  // -------------------------------------------------------------------------
  Future<void> saveTokenToFirestore(String uid) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      debugPrint('[NotificationService] FCM Token: $token');

      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {'fcmToken': token, 'fcmTokenUpdatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );

      // Keep it fresh if the token rotates
      _messaging.onTokenRefresh.listen((newToken) async {
        await FirebaseFirestore.instance.collection('users').doc(uid).set(
          {
            'fcmToken': newToken,
            'fcmTokenUpdatedAt': FieldValue.serverTimestamp()
          },
          SetOptions(merge: true),
        );
        debugPrint('[NotificationService] FCM Token refreshed: $newToken');
      });
    } catch (e) {
      debugPrint('[NotificationService] Error saving FCM token: $e');
    }
  }

  // -------------------------------------------------------------------------
  // Phase 4 – clearTokenFromFirestore()
  // Removes the token when the user logs out so they stop receiving pushes.
  // -------------------------------------------------------------------------
  Future<void> clearTokenFromFirestore(String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'fcmToken': FieldValue.delete()});
      debugPrint('[NotificationService] FCM Token cleared for user $uid');
    } catch (e) {
      debugPrint('[NotificationService] Error clearing FCM token: $e');
    }
  }

  // -------------------------------------------------------------------------
  // Phase 5 – setupInteractedMessage()
  // Handles notification taps that open the app from terminated / background.
  // Call AFTER runApp() so GoRouter is mounted.
  // Pass in the navigatorKey from app_router.dart.
  // -------------------------------------------------------------------------
  Future<void> setupInteractedMessage(GlobalKey<NavigatorState> navigatorKey) async {
    // App was terminated; user tapped notification to open it
    final RemoteMessage? initialMessage =
        await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationNavigation(initialMessage.data, navigatorKey);
    }

    // App was in background; user tapped notification to bring it forward
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationNavigation(message.data, navigatorKey);
    });
  }

  // -------------------------------------------------------------------------
  // Internal helpers
  // -------------------------------------------------------------------------

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint(
        '[NotificationService] Permission status: ${settings.authorizationStatus}');
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    // Only show if there is a notification payload; pure data messages are
    // handled separately.
    if (notification != null) {
      _localPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _highImportanceChannel.id,
            _highImportanceChannel.name,
            channelDescription: _highImportanceChannel.description,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
          ),
        ),
        payload: message.data['type'], // carry the notification type
      );
    }
  }

  // Notification was tapped while app was in the foreground
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint(
        '[NotificationService] Notification tapped (foreground), payload: ${response.payload}');
    // Navigation handled via setupInteractedMessage for background/terminated.
    // For foreground taps we rely on GoRouter being available via context;
    // actual routing is performed by the listener in setupInteractedMessage.
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    debugPrint(
        '[NotificationService] Background notification tapped, payload: ${response.payload}');
  }

  // ---------------------------------------------------------------------------
  // Phase 5 – Route to the correct screen based on notification type
  // ---------------------------------------------------------------------------
  void _handleNotificationNavigation(
    Map<String, dynamic> data,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    final type = data['type'] as String?;
    final context = navigatorKey.currentContext;
    if (context == null) return;

    debugPrint('[NotificationService] Handling navigation for type: $type');

    // Map notification types to routes.
    // All booking / mystery types go to the notifications screen so the user
    // can see the full detail and take action.
    switch (type) {
      case 'new_booking':
      case 'booking_accepted':
      case 'booking_rejected':
      case 'booking_completed':
      case 'booking_ongoing':
      case 'booking_cancellation':
      case 'booking_cancelled':
      case 'payment_received':
      case 'mystery_booking':
      case 'mystery_booked':
      case 'mystery_revealed':
      case 'mystery_booking_accepted':
      case 'mystery_accepted':
      case 'mystery_booking_declined':
      case 'mystery_declined':
      case 'mystery_auto_declined':
      case 'review_report':
      default:
        navigatorKey.currentState?.pushNamed('/notifications');
        break;
    }
  }
}
