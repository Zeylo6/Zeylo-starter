const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');
const FileItem = require('../models/fileModel');

async function generateUniqueCode() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

const register = async (req, res) => {
  try {
    const { username, password, role } = req.body;
    if (!username || !password || !role)
      return res.status(400).json({ error: 'username, password, role required' });

    const exists = await User.findOne({ username });
    if (exists) return res.status(409).json({ error: 'Username exists' });

    const hashed = await bcrypt.hash(password, 10);

    let user, attempts = 0;
    while (!user && attempts < 8) {
      const code = await generateUniqueCode();
      try {
        user = await User.create({ username, password: hashed, role, code });
      } catch (e) {
        if (e.code === 11000 && e.keyPattern?.code) { attempts++; continue; }
        throw e;
      }
    }
    if (!user) return res.status(500).json({ error: 'Code allocation failed' });

    res.status(201).json({
      id: user._id,
      username: user.username,
      role: user.role,
      code: user.code
    });
  } catch (e) {
    console.error('Register error:', e);
    res.status(500).json({ error: 'Register failed' });
  }
};

const login = async (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password)
      return res.status(400).json({ error: 'username and password required' });

    const user = await User.findOne({ username });
    if (!user) return res.status(401).json({ error: 'Invalid credentials' });

    const ok = await bcrypt.compare(password, user.password);
    if (!ok) return res.status(401).json({ error: 'Invalid credentials' });

    const secret = process.env.JWT_SECRET || process.env.JWT_STRING;
    if (!secret) return res.status(500).json({ error: 'Server misconfiguration' });

    // include code in token so controllers can authorize by code
    const token = jwt.sign(
      { sub: user._id.toString(), role: user.role, username: user.username, code: user.code },
      secret,
      { expiresIn: '1h' }
    );

    // fetch user files (fileLinks) for this user's code so client can load them after login
    let files = [];
    try {
      files = await FileItem.find({ code: user.code }).sort({ createdAt: -1 }).select('mail fileLinks createdAt');
    } catch (e) {
      console.error('Failed to fetch user files during login:', e);
    }

    return res.json({
      token,
      user: { id: user._id, username: user.username, role: user.role, code: user.code },
      files
    });
  } catch (e) {
    console.error('Login error:', e);
    return res.status(500).json({ error: 'Login failed' });
  }
};

const loginByCode = async (req, res) => {
  try {
    const { code } = req.body;
    if (!code) return res.status(400).json({ error: 'code required' });

    const user = await User.findOne({ code });
    if (!user) return res.status(401).json({ error: 'Invalid code' });

    const secret = process.env.JWT_SECRET || process.env.JWT_STRING;
    if (!secret) return res.status(500).json({ error: 'Server misconfiguration' });

    const token = jwt.sign(
      { sub: user._id.toString(), role: user.role, username: user.username, code: user.code },
      secret,
      { expiresIn: '1h' }
    );

    // include files for code-based login as well
    let files = [];
    try {
      files = await FileItem.find({ code: user.code }).sort({ createdAt: -1 }).select('mail fileLinks createdAt');
    } catch (e) {
      console.error('Failed to fetch user files during code login:', e);
    }

    return res.json({
      token,
      user: { id: user._id, username: user.username, role: user.role, code: user.code },
      files
    });
  } catch (e) {
    console.error('loginByCode error:', e);
    return res.status(500).json({ error: 'Login failed' });
  }
};

module.exports = { register, login, loginByCode };