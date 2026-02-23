const express = require('express');
const { verifyToken } = require('../middleware/auth');
const { getMe } = require('../controllers/meController');
const router = express.Router();

router.get('/', verifyToken, getMe);

module.exports = router;