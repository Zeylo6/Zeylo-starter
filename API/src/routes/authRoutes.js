const express = require('express');
const { register, login, loginByCode } = require('../controllers/authController');
const { verifyToken, requireAdmin } = require('../middleware/auth');
const { loginLimiter, codeLoginLimiter } = require('../middleware/rateLimit');

const router = express.Router();

// Admin-only user creation
router.post('/register', verifyToken, requireAdmin, register);

// Username/password login
router.post('/login', loginLimiter, login);

// Code-only login (for mobile)
router.post('/login-code', codeLoginLimiter, loginByCode);

module.exports = router;
