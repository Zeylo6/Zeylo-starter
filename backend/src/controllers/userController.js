const { db } = require('../config/firebase');

/**
 * POST /api/users/fcm-token
 * Body: { fcmToken }
 *
 * Saves the user's FCM token to their Firestore document
 * so push notifications can be delivered.
 */
const saveFCMToken = async (req, res) => {
  try {
    const uid = req.user.uid;
    const { fcmToken } = req.body;

    if (!fcmToken) {
      return res.status(400).json({ error: 'Missing required field: fcmToken' });
    }

    await db.collection('users').doc(uid).update({
      fcmToken,
    });

    return res.status(200).json({ success: true, message: 'FCM token saved successfully' });
  } catch (error) {
    console.error('Error saving FCM token:', error);
    return res.status(500).json({ error: 'Failed to save FCM token', details: error.message });
  }
};

module.exports = { saveFCMToken };
