const rateLimit = require('express-rate-limit');

// Per-IP limiter for username/password login
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 min
  max: 100,
  standardHeaders: true,
  legacyHeaders: false
});

// Per-code limiter for code-based login (fallback to IP)
const codeLoginLimiter = rateLimit({
  windowMs: 10 * 60 * 1000, // 10 min
  max: 30,
  // Prefer request body code, fallback to X-Forwarded-For or socket remote address
  keyGenerator: (req) => req.body?.code || req.headers['x-forwarded-for'] || req.socket?.remoteAddress || req.connection?.remoteAddress || '',
  message: { error: 'Too many attempts, try again later.' },
  standardHeaders: true,
  legacyHeaders: false
});

module.exports = { loginLimiter, codeLoginLimiter };