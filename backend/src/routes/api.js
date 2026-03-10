const express = require('express');
const router = express.Router();
const surprisesController = require('../controllers/surprises');
const verifyToken = require('../middleware/auth');

router.get('/health', (req, res) => res.status(200).send('OK'));

// Using verifyToken to protect the surprise generation endpoint
router.post('/surprises/generate', verifyToken, surprisesController.generateSurprise);

module.exports = router;
