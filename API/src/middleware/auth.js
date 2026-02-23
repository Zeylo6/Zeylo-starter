const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
  const h = req.headers.authorization;
  if (!h || !h.startsWith('Bearer '))
    return res.status(401).json({ error: 'Missing token' });

  const token = h.split(' ')[1];
  const secret = process.env.JWT_SECRET || process.env.JWT_STRING;
  if (!secret) return res.status(500).json({ error: 'Server misconfiguration' });

  try {
    req.user = jwt.verify(token, secret);
    next();
  } catch {
    return res.status(401).json({ error: 'Invalid token' });
  }
};

const requireAdmin = (req, res, next) => {
  if (req.user?.role !== 'admin')
    return res.status(403).json({ error: 'Admin only' });
  next();
};

module.exports = { verifyToken, requireAdmin };