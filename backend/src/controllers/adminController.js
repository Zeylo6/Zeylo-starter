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

module.exports = { sendWarning, banUser };
