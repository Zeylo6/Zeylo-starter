const { admin, db } = require('../config/firebase');

/**
 * Service to handle community-related logic and notifications.
 */

/**
 * Sends a push notification to a user when their post is liked.
 * @param {string} authorId - ID of the post author.
 * @param {string} likerName - Name of the person who liked the post.
 * @param {string} postId - ID of the liked post.
 */
const notifyPostLiked = async (authorId, likerName, postId) => {
  try {
    // 1. Get the author's FCM token from the users collection
    const userDoc = await db.collection('users').doc(authorId).get();
    if (!userDoc.exists) return;

    const userData = userDoc.data();
    const fcmToken = userData.fcmToken;

    // 2. Create an activity entry for the author
    await db.collection('activities').add({
      userId: authorId,
      type: 'post_like',
      title: 'New Like!',
      message: `${likerName} liked your post.`,
      relatedId: postId,
      isRead: false,
      createdAt: new Date(),
    });

    // 3. Send FCM notification if token exists
    if (fcmToken) {
      const message = {
        notification: {
          title: 'Zeylo Community',
          body: `${likerName} liked your post!`,
        },
        data: {
          type: 'post_like',
          postId: postId,
        },
        token: fcmToken,
      };

      await admin.messaging().send(message);
      console.log(`Notification sent to user ${authorId} for like on post ${postId}`);
    }
  } catch (error) {
    console.error('Error notifying post like:', error);
  }
};

/**
 * Sends a push notification to a user when someone comments on their post.
 * @param {string} authorId - ID of the post author.
 * @param {string} commenterName - Name of the person who commented.
 * @param {string} postId - ID of the post.
 * @param {string} commentText - The text of the comment.
 */
const notifyPostCommented = async (authorId, commenterName, postId, commentText) => {
  try {
    // 1. Get the author's FCM token
    const userDoc = await db.collection('users').doc(authorId).get();
    if (!userDoc.exists) return;

    const userData = userDoc.data();
    const fcmToken = userData.fcmToken;

    // 2. Create an activity entry
    await db.collection('activities').add({
      userId: authorId,
      type: 'post_comment',
      title: 'New Comment!',
      message: `${commenterName} commented: "${commentText}"`,
      relatedId: postId,
      isRead: false,
      createdAt: new Date(),
    });

    // 3. Send FCM notification
    if (fcmToken) {
      const message = {
        notification: {
          title: 'Zeylo Community',
          body: `${commenterName} commented on your post.`,
        },
        data: {
          type: 'post_comment',
          postId: postId,
        },
        token: fcmToken,
      };

      await admin.messaging().send(message);
      console.log(`Notification sent to user ${authorId} for comment on post ${postId}`);
    }
  } catch (error) {
    console.error('Error notifying post comment:', error);
  }
};

module.exports = {
  notifyPostLiked,
  notifyPostCommented,
};
