const express = require('express');
const router = express.Router();
const surprisesController = require('../controllers/surprises');
const adminController = require('../controllers/adminController');
const verifyToken = require('../middleware/auth');

router.get('/health', (req, res) => res.status(200).send('OK'));

// Using verifyToken to protect the surprise generation endpoint
router.post('/surprises/generate', verifyToken, surprisesController.generateSurprise);

// Admin actions
router.post('/admin/send-warning-email', verifyToken, adminController.sendWarning);
router.post('/admin/ban-user', verifyToken, adminController.banUser);
router.post('/admin/delete-experience', verifyToken, adminController.deleteExperience);

module.exports = router;
