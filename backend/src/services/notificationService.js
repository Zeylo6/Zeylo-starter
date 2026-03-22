const { admin, db } = require('../config/firebase');

/**
 * Centralized service for sending FCM push notifications.
 */

/**
 * Sends a push notification to a specific user.
 * @param {string} userId - ID of the user to receive the notification.
 * @param {Object} payload - The notification payload { title, body, data }.
 */
const sendPushNotification = async (userId, { title, body, data }) => {
  try {
    // 1. Get the user's FCM token from the users collection
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      console.warn(`[NotificationService] User ${userId} not found.`);
      return;
    }

    const userData = userDoc.data();
    const fcmToken = userData.fcmToken;

    if (!fcmToken) {
      console.log(`[NotificationService] No FCM token for user ${userId}. Skipping push.`);
      return;
    }

    // 2. Create an in-app activity record in Firestore first
    // This ensures the notification appears in the app's 'Notifications' tab even if push fails.
    await db.collection('activities').add({
      userId: userId,
      type: data?.type || 'system',
      title: title || 'Zeylo',
      message: body || '',
      relatedId: data?.bookingId || data?.postId || '',
      bookingId: data?.bookingId || '',
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 3. Construct the FCM message
    const message = {
      notification: {
        title: title || 'Zeylo',
        body: body || '',
      },
      data: data || {},
      token: fcmToken,
    };

    // 3. Send the notification via Firebase Admin
    const response = await admin.messaging().send(message);
    console.log(`[NotificationService] Successfully sent push to ${userId}:`, response);
    return response;
  } catch (error) {
    console.error(`[NotificationService] Error sending push to ${userId}:`, error);
  }
};

/**
 * Sends a notification to a host about a new booking or status change.
 */
const notifyHostOfBooking = async (hostId, { title, body, bookingId, type }) => {
  return sendPushNotification(hostId, {
    title: title || 'New Booking!',
    body: body || 'You have a new booking request.',
    data: {
      type: type || 'new_booking',
      bookingId: bookingId,
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
    },
  });
};

/**
 * Sends a notification to a seeker about their booking status.
 */
const notifySeekerOfBookingUpdate = async (seekerId, { title, body, bookingId, type }) => {
  return sendPushNotification(seekerId, {
    title: title || 'Booking Update',
    body: body || 'Your booking status has changed.',
    data: {
      type: type || 'booking_update',
      bookingId: bookingId,
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
    },
  });
};

module.exports = {
  sendPushNotification,
  notifyHostOfBooking,
  notifySeekerOfBookingUpdate,
};
