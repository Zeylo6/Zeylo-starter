const { notifyPostLiked, notifyPostCommented } = require('../services/communityService');
const { db } = require('../config/firebase');

/**
 * Controller for community-related actions triggered by the backend
 * (e.g. from client calls after direct Firestore updates)
 */

const handleLikeNotification = async (req, res) => {
  try {
    const { authorId, likerName, postId } = req.body;

    if (!authorId || !likerName || !postId) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    await notifyPostLiked(authorId, likerName, postId);

    return res.status(200).json({ success: true, message: 'Like notification processed' });
  } catch (error) {
    console.error('Error in handleLikeNotification:', error);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
};

const handleCommentNotification = async (req, res) => {
  try {
    const { authorId, commenterName, postId, commentText } = req.body;

    if (!authorId || !commenterName || !postId || !commentText) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    await notifyPostCommented(authorId, commenterName, postId, commentText);

    return res.status(200).json({ success: true, message: 'Comment notification processed' });
  } catch (error) {
    console.error('Error in handleCommentNotification:', error);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
};

module.exports = {
  handleLikeNotification,
  handleCommentNotification,
};
