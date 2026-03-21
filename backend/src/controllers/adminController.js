const { db } = require('../config/firebase');
const { sendWarningEmail } = require('../services/emailService');

/**
 * POST /api/admin/send-warning-email
 * Body: { reportedUserId, reason, details }
 *
 * - Verifies the caller is an admin
 * - Fetches the reported user's email from Firestore
 * - Sends a warning email via Nodemailer
 */
const sendWarning = async (req, res) => {
  try {
    const callerUid = req.user.uid;

    // 1. Verify the caller is an admin
    const callerDoc = await db.collection('users').doc(callerUid).get();
    if (!callerDoc.exists || callerDoc.data().role !== 'admin') {
      return res.status(403).json({ error: 'Forbidden: Only admins can perform this action.' });
    }

    const { reportedUserId, reason, details } = req.body;

    if (!reportedUserId || !reason) {
      return res.status(400).json({ error: 'Missing required fields: reportedUserId, reason' });
    }

    // 2. Get the reported user's email and name from Firestore
    const userDoc = await db.collection('users').doc(reportedUserId).get();
    if (!userDoc.exists) {
      return res.status(404).json({ error: 'Reported user not found.' });
    }

    const userData = userDoc.data();
    const userEmail = userData.email;
    const userName = userData.displayName || userData.name || 'User';

    if (!userEmail) {
      return res.status(400).json({ error: 'Reported user has no email address on file.' });
    }

    // 3. Send the warning email
    await sendWarningEmail(userEmail, userName, reason, details || '');

    return res.status(200).json({
      success: true,
      message: `Warning email sent to ${userEmail}`,
    });
  } catch (error) {
    console.error('Error sending warning email:', error);
    return res.status(500).json({ error: 'Failed to send warning email.', details: error.message });
  }
};


/**
 * POST /api/admin/ban-user
 * Body: { targetUserId, reason }
 *
 * - Verifies the caller is an admin
 * - Updates the target user document with isBanned: true
 */
const banUser = async (req, res) => {
  try {
    const callerUid = req.user.uid;

    // 1. Verify the caller is an admin
    const callerDoc = await db.collection('users').doc(callerUid).get();
    if (!callerDoc.exists || callerDoc.data().role !== 'admin') {
      return res.status(403).json({ error: 'Forbidden: Only admins can perform this action.' });
    }

    const { targetUserId, reason } = req.body;

    if (!targetUserId) {
      return res.status(400).json({ error: 'Missing required field: targetUserId' });
    }

    // 2. Update the target user's document
    const userRef = db.collection('users').doc(targetUserId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User not found.' });
    }

    await userRef.update({
      isBanned: true,
      bannedAt: new Date(),
      banReason: reason || 'Violation of platform policies',
      status: 'banned'
    });

    // 3. Log the action
    await db.collection('admin_actions').add({
      actionType: 'account_ban',
      targetUserId,
      reason: reason || 'Violation of platform policies',
      callerUid,
      createdAt: new Date()
    });

    return res.status(200).json({
      success: true,
      message: `User ${targetUserId} has been banned successfully.`,
    });
  } catch (error) {
    console.error('Error banning user:', error);
    return res.status(500).json({ error: 'Failed to ban user.', details: error.message });
  }
};

/**
 * POST /api/admin/delete-experience
 * Body: { experienceId, hostId, title }
 *
 * - Verifies the caller is an admin
 * - Deletes the experience document
 * - Cancels related bookings
 * - Sends notifications to host and seekers
 */
const deleteExperience = async (req, res) => {
  try {
    const callerUid = req.user.uid;

    // 1. Verify the caller is an admin
    const callerDoc = await db.collection('users').doc(callerUid).get();
    if (!callerDoc.exists || callerDoc.data().role !== 'admin') {
      return res.status(403).json({ error: 'Forbidden: Only admins can perform this action.' });
    }

    const { experienceId, hostId, title } = req.body;

    if (!experienceId) {
      return res.status(400).json({ error: 'Missing required field: experienceId' });
    }

    const batch = db.batch();

    // 2. Delete Experience Document
    const expRef = db.collection('experiences').doc(experienceId);
    batch.delete(expRef);

    // 3. Fetch all upcoming/active Bookings related to this experience
    const bookingsSnapshot = await db.collection('bookings')
      .where('experienceId', '==', experienceId)
      .get();

    const uniqueSeekerIds = new Set();

    bookingsSnapshot.forEach(doc => {
      batch.update(doc.ref, {
        status: 'cancelled',
        cancellationReason: 'Experience Removed by Administrator',
      });
      const data = doc.data();
      if (data.userId) {
        uniqueSeekerIds.add(data.userId);
      }
    });

    // 4. Queue Notification to Host
    if (hostId) {
      const hostNotifRef = db.collection('activities').doc();
      batch.set(hostNotifRef, {
        userId: hostId,
        type: 'admin_action',
        title: 'Listing Removed',
        message: `Your experience "${title || 'Untitled'}" was removed by an Administrator.`,
        isRead: false,
        createdAt: new Date(),
      });
    }

    // 5. Queue Notifications to Affected Seekers
    for (const seekerId of uniqueSeekerIds) {
      const seekerNotifRef = db.collection('activities').doc();
      batch.set(seekerNotifRef, {
        userId: seekerId,
        type: 'booking_cancelled',
        title: 'Experience Cancelled',
        message: `Unfortunately, the experience "${title || 'Untitled'}" was removed from the platform and your booking has been cancelled.`,
        isRead: false,
        createdAt: new Date(),
      });
    }

    await batch.commit();

    return res.status(200).json({
      success: true,
      message: 'Experience successfully deleted and notifications dispatched.',
    });
  } catch (error) {
    console.error('Error deleting experience:', error);
    return res.status(500).json({ error: 'Failed to delete experience.', details: error.message });
  }
};

module.exports = { sendWarning, banUser, deleteExperience };
