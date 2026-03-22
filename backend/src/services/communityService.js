const { db } = require('../config/firebase');
const notificationService = require('./notificationService');

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
    // 1. Create an activity entry for the author
    await db.collection('activities').add({
      userId: authorId,
      type: 'post_like',
      title: 'New Like!',
      message: `${likerName} liked your post.`,
      relatedId: postId,
      isRead: false,
      createdAt: new Date(),
    });

    // 2. Send FCM notification
    await notificationService.sendPushNotification(authorId, {
      title: 'Zeylo Community',
      body: `${likerName} liked your post!`,
      data: {
        type: 'post_like',
        postId: postId,
      },
    });
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
    // 1. Create an activity entry
    await db.collection('activities').add({
      userId: authorId,
      type: 'post_comment',
      title: 'New Comment!',
      message: `${commenterName} commented: "${commentText}"`,
      relatedId: postId,
      isRead: false,
      createdAt: new Date(),
    });

    // 2. Send FCM notification
    await notificationService.sendPushNotification(authorId, {
      title: 'Zeylo Community',
      body: `${commenterName} commented on your post.`,
      data: {
        type: 'post_comment',
        postId: postId,
      },
    });
  } catch (error) {
    console.error('Error notifying post comment:', error);
  }
};

module.exports = {
  notifyPostLiked,
  notifyPostCommented,
};
