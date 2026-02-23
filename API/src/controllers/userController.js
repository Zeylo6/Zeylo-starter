const bcrypt = require('bcryptjs');
const mongoose = require('mongoose');
const User = require('../models/userModel');

async function generateUniqueCode() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

function sanitize(user) {
  const { _id, username, role, code, createdAt, updatedAt } = user;
  return { id: _id, username, role, code, createdAt, updatedAt };
}

const listUsers = async (req, res) => {
  try {
    const { q, role, page = 1, limit = 50 } = req.query;
    const filter = {};
    if (role) filter.role = role;
    if (q) filter.username = { $regex: String(q), $options: 'i' };

    const skip = (Number(page) - 1) * Number(limit);
    const [items, total] = await Promise.all([
      User.find(filter).sort({ createdAt: -1 }).skip(skip).limit(Number(limit)),
      User.countDocuments(filter),
    ]);

    res.json({
      total,
      page: Number(page),
      limit: Number(limit),
      items: items.map(sanitize),
    });
  } catch (e) {
    console.error('listUsers error:', e);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
};

const getUser = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.isValidObjectId(id)) return res.status(400).json({ error: 'Invalid id' });
    const user = await User.findById(id);
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(sanitize(user));
  } catch (e) {
    console.error('getUser error:', e);
    res.status(500).json({ error: 'Failed to fetch user' });
  }
};

const createUser = async (req, res) => {
  try {
    const { username, password, role } = req.body;
    if (!username || !password || !role)
      return res.status(400).json({ error: 'username, password, role required' });

    const exists = await User.findOne({ username });
    if (exists) return res.status(409).json({ error: 'Username exists' });

    const hashed = await bcrypt.hash(password, 10);

    let user;
    for (let attempts = 0; attempts < 8 && !user; attempts++) {
      try {
        const code = await generateUniqueCode();
        user = await User.create({ username, password: hashed, role, code });
      } catch (e) {
        if (e.code === 11000 && e.keyPattern?.code) continue; // retry on code collision
        throw e;
      }
    }
    if (!user) return res.status(500).json({ error: 'Code allocation failed' });

    res.status(201).json(sanitize(user));
  } catch (e) {
    console.error('createUser error:', e);
    res.status(500).json({ error: 'Failed to create user' });
  }
};

const updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.isValidObjectId(id)) return res.status(400).json({ error: 'Invalid id' });

    const updates = {};
    const { username, role, password } = req.body;

    if (username) updates.username = username;
    if (role) updates.role = role;
    if (password) updates.password = await bcrypt.hash(password, 10);

    const current = await User.findById(id);
    if (!current) return res.status(404).json({ error: 'User not found' });

    // Prevent demoting the last admin
    if (current.role === 'admin' && role === 'user') {
      const adminCount = await User.countDocuments({ role: 'admin' });
      if (adminCount <= 1) {
        return res.status(400).json({ error: 'Cannot demote the last admin' });
      }
    }

    const updated = await User.findByIdAndUpdate(id, updates, { new: true, runValidators: true });
    res.json(sanitize(updated));
  } catch (e) {
    if (e.code === 11000 && e.keyPattern?.username) {
      return res.status(409).json({ error: 'Username already in use' });
    }
    console.error('updateUser error:', e);
    res.status(500).json({ error: 'Failed to update user' });
  }
};

const deleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.isValidObjectId(id)) return res.status(400).json({ error: 'Invalid id' });

    // Prevent deleting yourself
    if (req.user?.sub === id) return res.status(400).json({ error: 'Cannot delete your own account' });

    const user = await User.findById(id);
    if (!user) return res.status(404).json({ error: 'User not found' });

    // Prevent removing the last admin
    if (user.role === 'admin') {
      const adminCount = await User.countDocuments({ role: 'admin' });
      if (adminCount <= 1) {
        return res.status(400).json({ error: 'Cannot delete the last admin' });
      }
    }

    await User.findByIdAndDelete(id);
    res.status(204).send();
  } catch (e) {
    console.error('deleteUser error:', e);
    res.status(500).json({ error: 'Failed to delete user' });
  }
};

module.exports = { listUsers, getUser, createUser, updateUser, deleteUser };