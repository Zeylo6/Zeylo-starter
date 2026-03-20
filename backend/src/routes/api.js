const express = require('express');
const router = express.Router();
const surprisesController = require('../controllers/surprises');
const adminController = require('../controllers/adminController');
const aiController = require('../controllers/aiController');
const paymentController = require('../controllers/paymentController');
const communityController = require('../controllers/communityController');
const verifyToken = require('../middleware/auth');

router.get('/health', (req, res) => res.status(200).send('OK'));

// Using verifyToken to protect the surprise generation endpoint
router.post('/surprises/generate', verifyToken, surprisesController.generateSurprise);

// Admin actions
router.post('/admin/send-warning-email', verifyToken, adminController.sendWarning);
router.post('/admin/ban-user', verifyToken, adminController.banUser);
router.post('/admin/delete-experience', verifyToken, adminController.deleteExperience);

// Gemini AI Gen Routes
router.post('/ai/enhance', verifyToken, aiController.enhanceText);
router.post('/ai/chain/generate', verifyToken, aiController.generateChain);
router.post('/ai/mystery/generate', verifyToken, aiController.generateSurprise);

// Payment Routes
router.post('/payments/create-intent', verifyToken, paymentController.createIntent);
router.post('/payments/webhook', express.raw({ type: 'application/json' }), paymentController.handleWebhook);

// Community Routes
router.post('/community/notify-like', verifyToken, communityController.handleLikeNotification);
router.post('/community/notify-comment', verifyToken, communityController.handleCommentNotification);

module.exports = router;
